class DashboardChartService
  def self.call(addresses, date_range)
    new(addresses, date_range).call
  end

  def initialize(addresses, date_range)
    @addresses = addresses
    @date_range = date_range
  end

  def call
    {
      labels: labels,
      consumption: consumption_data,
      production: production_data,
      sharing: sharing_data,
      totals: totals
    }
  end

  private

  def eans
    @eans ||= @addresses.pluck(:ean)
  end

  def customer_eans
    @customer_eans ||= @addresses.customer.pluck(:ean)
  end

  def supplier_eans
    @supplier_eans ||= @addresses.supplier.pluck(:ean)
  end

  def start_date
    @start_date ||= case @date_range
    when "week" then 7.days.ago.to_date
    when "quarter" then 90.days.ago.to_date
    else 30.days.ago.to_date
    end
  end

  def end_date
    @end_date ||= Date.current
  end

  def group_format
    @date_range == "quarter" ? :week : :day
  end

  def labels
    if group_format == :week
      (start_date..end_date).step(7).map { |d| I18n.l(d, format: :short) }
    else
      (start_date..end_date).map { |d| I18n.l(d, format: :short) }
    end
  end

  def readings_in_period
    @readings_in_period ||= Edc::Reading.for_eans(eans).in_period(start_date, end_date)
  end

  def shares_in_period
    @shares_in_period ||= Edc::Share.for_eans(eans).in_period(start_date, end_date)
  end

  def consumption_data
    return [] if customer_eans.empty?
    group_readings(customer_eans)
  end

  def production_data
    return [] if supplier_eans.empty?
    group_readings(supplier_eans)
  end

  def sharing_data
    grouped = shares_in_period
      .where(to_ean: customer_eans)
      .group(date_trunc_sql)
      .sum(:value)

    fill_data(grouped)
  end

  def totals
    {
      consumption: readings_in_period.where(ean: customer_eans).sum("COALESCE(final, 0) - COALESCE(original, 0)").round(2),
      production: readings_in_period.where(ean: supplier_eans).sum("COALESCE(final, 0) - COALESCE(original, 0)").round(2),
      sharing: shares_in_period.where(to_ean: customer_eans).sum(:value).round(2)
    }
  end

  def group_readings(target_eans)
    grouped = readings_in_period
      .where(ean: target_eans)
      .group(date_trunc_sql)
      .sum("COALESCE(final, 0) - COALESCE(original, 0)")

    fill_data(grouped)
  end

  def fill_data(grouped)
    if group_format == :week
      (start_date..end_date).step(7).map { |d| grouped[d.to_s]&.round(2) || 0 }
    else
      (start_date..end_date).map { |d| grouped[d.to_s]&.round(2) || 0 }
    end
  end

  def date_trunc_sql
    if group_format == :week
      Arel.sql("DATE_TRUNC('week', shared_at)::date")
    else
      Arel.sql("shared_at::date")
    end
  end
end

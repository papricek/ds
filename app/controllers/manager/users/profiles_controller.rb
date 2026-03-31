class Manager::Users::ProfilesController < Manager::Users::BaseController
  def show
    @customer_eans = @user.addresses.customer.pluck(:ean)
    @supplier_eans = @user.addresses.supplier.pluck(:ean)
    all_eans = @customer_eans + @supplier_eans

    @stats = {
      yesterday: compute_stats(all_eans, 1.day.ago.all_day),
      week: compute_stats(all_eans, 7.days.ago.beginning_of_day..Time.current),
      year: compute_stats(all_eans, Date.current.beginning_of_year.beginning_of_day..Time.current)
    }
  end

  private

  def compute_stats(eans, period)
    readings = Edc::Reading.where(ean: eans, shared_at: period)
    shares = Edc::Share.where(shared_at: period)

    {
      production: readings.where(ean: @supplier_eans).sum("ABS(COALESCE(final, 0) - COALESCE(original, 0))").round(2),
      consumption: readings.where(ean: @customer_eans).sum("ABS(COALESCE(final, 0) - COALESCE(original, 0))").round(2),
      sharing: shares.where(to_ean: @customer_eans).sum(:value).abs.round(2)
    }
  end
end

module Edc
  class Reading < ApplicationRecord
    self.table_name = "edc_readings"

    validates :ean, presence: true
    validates :shared_at, presence: true
    validates :shared_at, uniqueness: { scope: :ean }

    scope :for_ean, ->(ean) { where(ean: ean) }
    scope :for_eans, ->(eans) { where(ean: eans) }
    scope :in_period, ->(start_at, end_at) { where(shared_at: start_at.beginning_of_day..end_at.end_of_day) }
  end
end

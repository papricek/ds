module Edc
  class Share < ApplicationRecord
    self.table_name = "edc_shares"

    validates :from_ean, presence: true
    validates :to_ean, presence: true
    validates :value, presence: true, numericality: true
    validates :shared_at, presence: true
    validates :shared_at, uniqueness: { scope: [:from_ean, :to_ean] }

    scope :for_sharing, ->(sharing) { where(from_ean: sharing.from_ean, to_ean: sharing.to_ean) }
    scope :in_period, ->(start_at, end_at) { where(shared_at: start_at.beginning_of_day..end_at.end_of_day) }
    scope :for_eans, ->(eans) { where(from_ean: eans).or(where(to_ean: eans)) }
  end
end

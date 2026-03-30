class GroupSupplierAllocation < ApplicationRecord
  belongs_to :group_customer

  validates :ean, presence: true
  validates :allocation_ratio, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
  validates :allocation_order, numericality: { greater_than: 0 }
end

class GroupCustomer < ApplicationRecord
  belongs_to :group

  has_many :group_supplier_allocations, dependent: :destroy

  validates :ean, presence: true
  validates :ean, uniqueness: { scope: :group_id }

  scope :active, -> { where("valid_from IS NULL OR valid_from <= ?", Date.current).where("valid_to IS NULL OR valid_to >= ?", Date.current) }
end

class Sharing < ApplicationRecord
  belongs_to :account
  belongs_to :from_address, class_name: "Address"
  belongs_to :to_address, class_name: "Address"

  enum :status, { pending: "pending", active: "active", inactive: "inactive" }

  validates :from_ean, presence: true
  validates :to_ean, presence: true
  validates :from_ean, uniqueness: { scope: [:to_ean, :account_id] }
  validates :fixed_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :set_eans_from_addresses

  scope :active, -> { where(status: :active) }

  def supplier
    from_address&.user
  end

  def customer
    to_address&.user
  end

  private

  def set_eans_from_addresses
    self.from_ean ||= from_address&.ean
    self.to_ean ||= to_address&.ean
  end
end

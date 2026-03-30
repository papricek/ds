class Address < ApplicationRecord
  belongs_to :user
  belongs_to :account

  enum :role, { customer: "customer", supplier: "supplier" }

  validates :ean, presence: true
  validates :role, presence: true
  validates :ean, uniqueness: { scope: :account_id }
end

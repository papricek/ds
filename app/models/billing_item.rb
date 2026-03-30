class BillingItem < ApplicationRecord
  belongs_to :billing
  belongs_to :sharing, optional: true

  enum :kind, { sharings: "sharings" }
  enum :transaction_type, { pay: "pay", receive: "receive" }

  validates :transaction_type, presence: true
  validates :amount, numericality: true
  validates :price, numericality: true
end

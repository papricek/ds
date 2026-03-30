class Billing < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_many :billing_items, dependent: :destroy
  has_one_attached :document

  enum :kind, { receipt: "receipt" }
  enum :status, { active: "active", paid: "paid" }

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :kind, presence: true
  validates :status, presence: true

  scope :for_period, ->(start_at, end_at) { where(start_at: start_at, end_at: end_at) }

  def total_to_pay
    billing_items.where(transaction_type: :pay).sum(:price)
  end

  def total_to_receive
    billing_items.where(transaction_type: :receive).sum(:price)
  end

  def net_amount
    total_to_receive - total_to_pay
  end

  def subtotal
    net_amount.abs
  end

  def vat_amount
    0
  end

  def total_with_vat
    subtotal + vat_amount
  end

  def total_kwh
    billing_items.sum(:amount)
  end

  def pdf_filename
    "doklad-#{variable_symbol || id}.pdf"
  end
end

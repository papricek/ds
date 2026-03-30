class Address < ApplicationRecord
  belongs_to :user
  belongs_to :account

  enum :role, { customer: "customer", supplier: "supplier" }

  has_many :from_sharings, class_name: "Sharing", foreign_key: :from_address_id, dependent: :destroy
  has_many :to_sharings, class_name: "Sharing", foreign_key: :to_address_id, dependent: :destroy

  validates :ean, presence: true
  validates :role, presence: true
  validates :ean, uniqueness: { scope: :account_id }
end

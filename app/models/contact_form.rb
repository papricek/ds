class ContactForm < ApplicationRecord
  attribute :website_url, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :phone, presence: true
end

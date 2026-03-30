class Account < ApplicationRecord
  include BooleanSettingsAccessors

  store :settings, accessors: [
    :issue_day_in_month,
    :supply_day_in_month,
    :due_days,
    :billing_copy_email
  ], default: {}, coder: JSON, prefix: true

  has_one_attached :logo

  has_many :users, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :sharings, dependent: :destroy
  has_one :credential, dependent: :destroy

  before_validation { self.subdomain = nil if subdomain.blank? }

  validates :name, presence: true
  validates :subdomain, uniqueness: true, allow_nil: true
  validates :subdomain, format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }, allow_nil: true

  def light?
    plan == "light"
  end

  def full?
    plan == "full"
  end
end

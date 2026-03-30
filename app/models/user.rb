class User < ApplicationRecord
  SUPERADMINS = [
    "patrikjira@gmail.com"
  ]

  has_secure_password

  belongs_to :account
  has_many :user_tokens, dependent: :destroy
  has_many :addresses, dependent: :destroy

  enum :role, { manager: "manager", user: "user" }, default: :user

  validates :name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: {
    with: %r{\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z}i
  }
  validates :role, inclusion: { in: %w[manager user] }

  scope :confirmed, -> { where(confirmed: true) }
  scope :unconfirmed, -> { where(confirmed: false) }

  scope :by_confirmation_token, ->(token) {
    joins(:user_tokens)
    .merge(UserToken.confirmation.valid)
    .where(user_tokens: { token: token })
  }
  scope :by_password_reset_token, ->(token) {
    joins(:user_tokens)
    .merge(UserToken.password_reset.valid)
    .where(user_tokens: { token: token })
  }

  before_validation :normalize_email

  def superadmin?
    SUPERADMINS.include?(email)
  end

  def generate_password_reset_token
    user_tokens.create!(kind: :password_reset,
                        issued_at: Time.current,
                        expires_at: 1.day.from_now)
  end

  def password_reset_token
    user_tokens.password_reset.last&.token
  end

  def confirmation_token
    user_tokens.confirmation.last&.token
  end

  def confirm!
    user_tokens.confirmation.destroy_all
    update_columns(confirmed: true)
  end

  def password_reset!
    user_tokens.password_reset.destroy_all
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end

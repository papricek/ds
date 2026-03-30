class UserToken < ApplicationRecord
  belongs_to :user
  before_create :generate_unique_token

  enum :kind, %i[confirmation password_reset]

  scope :valid, -> { where("issued_at < ? AND expires_at > ?", Time.current, Time.current) }

  def expired?
    expires_at < Time.current
  end

  private

  def generate_unique_token
    10.times do
      new_token = SecureRandom.hex(10)
      unless UserToken.where(token: new_token).exists?
        self.token = new_token
        break new_token
      end
    end
  end
end

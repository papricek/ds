class Credential < ApplicationRecord
  belongs_to :account

  encrypts :username
  encrypts :password
end

class Current < ActiveSupport::CurrentAttributes
  attribute :account, :user, :impersonated
end

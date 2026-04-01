require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = build(:user, account: @account)
    assert user.valid?
  end

  test "requires name" do
    user = build(:user, account: @account, name: nil)
    assert_not user.valid?
  end

  test "requires email" do
    user = build(:user, account: @account, email: nil)
    assert_not user.valid?
  end

  test "email must be unique" do
    create(:user, account: @account, email: "test@example.com")
    user = build(:user, account: @account, email: "test@example.com")
    assert_not user.valid?
  end

  test "email normalized to downcase" do
    user = create(:user, account: @account, email: "TEST@Example.COM")
    assert_equal "test@example.com", user.email
  end

  test "authenticates with correct password" do
    user = create(:user, account: @account, password: "secret123")
    assert user.authenticate("secret123")
    assert_not user.authenticate("wrong")
  end

  test "admin role" do
    user = create(:admin, account: @account)
    assert user.admin?
    assert_not user.user?
  end

  test "user role by default" do
    user = create(:user, account: @account)
    assert user.user?
    assert_not user.admin?
  end

  test "generate password reset token" do
    user = create(:user, account: @account)
    assert_difference "UserToken.count", 1 do
      user.generate_password_reset_token
    end
    token = user.user_tokens.last
    assert token.password_reset?
    assert token.expires_at > Time.current
  end
end

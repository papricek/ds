require "test_helper"
require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [ 1400, 900 ], headless: true)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite

  setup do
    @account = create(:account)
    @manager = create(:manager, account: @account)
  end

  private

  def login_as(user, password: "password123")
    visit new_session_path
    fill_in "email", with: user.email
    fill_in "password", with: password
    click_button I18n.t("sessions.login")
  end
end

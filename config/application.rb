require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Litelink
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Prague"
    config.i18n.default_locale = :cs
    config.i18n.available_locales = [:cs, :en]

    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.test_framework :test_unit, fixture: false
      g.factory_bot suffix: "factory"
    end
  end
end

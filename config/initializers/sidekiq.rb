require "sidekiq-scheduler"

if Rails.env.development? || Rails.env.test?
  silence_warnings do
    require "sidekiq/testing"
    Sidekiq::Testing.inline!
  end
  Sidekiq.logger.level = Logger::WARN
else
  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
      reconnect_attempts: 3,
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }

    config[:retry] = false
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
      reconnect_attempts: 3,
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }
  end
end

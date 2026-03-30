module BooleanSettingsAccessors
  extend ActiveSupport::Concern

  included do
    def self.boolean_settings_accessors(*settings)
      settings.each do |setting|
        define_method("settings_#{setting}=") do |value|
          bool_value = value.is_a?(String) ? (value != "0") : value
          super(bool_value)
        end

        define_method("settings_#{setting}") do
          value = super()
          value.nil? ? true : value
        end

        define_method("settings_#{setting}?") do
          value = send("settings_#{setting}")
          value == "1" || value == true
        end
      end
    end
  end
end

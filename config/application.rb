require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MoneyUnicorn
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.encoding = "utf-8"
    config.time_zone = "Europe/Paris"
    config.active_record.strict_loading_by_default = true
    config.active_record.strict_loading_mode = :n_plus_one_only
    config.active_record.action_on_strict_loading_violation = :log
    config.active_storage.variant_processor = :vips
    config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end

require_relative 'boot'

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'yaml'

SETTINGS = YAML.safe_load_file(File.expand_path('settings.yml', __dir__))
SETTINGS.merge! SETTINGS.fetch(Rails.env, {})
SETTINGS.symbolize_keys!

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OhanaApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'

      g.view_specs false
      g.helper_specs false
    end

    # Configuration for the application, engines, and railties goes here.
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run 'rake -D time' for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # config.eager_load_paths << Rails.root.join('extras')

    # Don't generate system test files.
    config.generators.system_tests = nil

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.active_record.schema_format = :sql

    # CORS support
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource %r{/locations|organizations|search/*},
                 headers: :any,
                 methods: %i[get put patch post delete],
                 expose: %w[Etag Last-Modified Link X-Total-Count]
      end
    end

    # This is required to be able to pass in an empty array as a JSON parameter
    # when updating a Postgres array field. Otherwise, Rails will convert the
    # empty array to `nil`. Search for "deep munge" on the rails/rails GitHub
    # repo for more details.
    config.action_dispatch.perform_deep_munge = false

    config.action_controller.per_form_csrf_tokens = true

    config.active_record.time_zone_aware_types = [:datetime]
  end
end

require 'active_support/core_ext/integer/time'

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = true
  config.action_view.cache_template_loading = true

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV['CI'].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }
  config.cache_store = :null_store

  # This should be false or else some tests will fail.
  config.consider_all_requests_local = false

  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  # Required for specs to pass. Any host value should work.
  config.action_mailer.default_url_options = { host: 'example.com' }
  config.action_mailer.perform_caching = false

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Bullet gem config
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.raise = true
    Bullet.add_safelist(
      type: :n_plus_one_query, class_name: 'Location', association: :address
    )
    Bullet.add_safelist(
      type: :n_plus_one_query, class_name: 'Location', association: :organization
    )
    Bullet.add_safelist(
      type: :n_plus_one_query, class_name: 'Phone', association: :contact
    )
    Bullet.add_safelist(
      type: :n_plus_one_query, class_name: 'Phone', association: :service
    )
    Bullet.add_safelist(
      type: :n_plus_one_query, class_name: 'Phone', association: :organization
    )
    Bullet.add_safelist(
      type: :n_plus_one_query, class_name: 'Service', association: :location
    )
    Bullet.add_safelist(
      type: :unused_eager_loading, class_name: 'Service', association: :program
    )
  end
end

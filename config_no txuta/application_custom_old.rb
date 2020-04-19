module Consul
  class Application < Rails::Application
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'eu-ES'
    config.i18n.available_locales = [:en, :es, 'eu-ES']
    #config.i18n.default_locale = :en
    #config.i18n.available_locales = [:en, :es, :fr, :nl, 'pt-BR']

    config.i18n.fallbacks = {'eu-ES' => 'en'}

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'custom', '**', '*.{rb,yml}')]

    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Add lib to the autoload path
    config.autoload_paths << Rails.root.join('lib')
    config.time_zone = 'Madrid'
    config.active_job.queue_adapter = :delayed_job

    # CONSUL specific custom overrides
    # Read more on documentation:
    # * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md
    # * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md
    #
    config.autoload_paths << "#{Rails.root}/app/controllers/custom"
    config.autoload_paths << "#{Rails.root}/app/models/custom"
    config.paths['app/views'].unshift(Rails.root.join('app', 'views', 'custom'))
  end
end

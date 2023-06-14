require "govuk_app_config/govuk_prometheus_exporter"

# Use Sidekiq strict args to force Sidekiq 6 deprecations to error ahead of upgrade to Sidekiq 7
Sidekiq.strict_args!

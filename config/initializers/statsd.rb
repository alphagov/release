# Statsd receives packets over UDP, so even if the daemon isn't running on
# your machine (e.g. in development) everything should work fine
STATSD = Statsd.new(ENV["STATSD_HOST"] || "localhost", 8125).tap do |c|
  c.namespace = (ENV["GOVUK_STATSD_PREFIX"] || "govuk.app.release").to_s
end

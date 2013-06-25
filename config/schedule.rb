$: << '.'

# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'

# We need Rake to use our own environment
job_type :rake, "cd :path && govuk_setenv release bundle exec rake :task --silent :output"

## 14:45 is during our regular release slot, this may have to change
## post-April. 2am is our regular time for this.
every "0 12 * * 1-5", roles: [:primary] do
  rake 'whitehall_release_candidate:announce'
end

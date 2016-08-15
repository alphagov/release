require 'yaml'
require 'aws-sdk'

namespace :pg do

  def conf
    @conf ||= YAML.load_file("#{Rails.root}/config/database.yml")
  end

  def username
    @username ||= conf['development']['username']
  end

  def database
    @database ||= conf['development']['database']
  end

  desc "Create release user and load schemas"
  task :create_user do
    %x[sudo su - postgres createuser -s #{username}]
  end

  task :load do
    Rake::Task['db:create:all'].invoke
    Rake::Task['db:migrate'].invoke
  end

  task :get_data do
    data = Aws::S3::Resource.new(
      region: 'eu-west-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    )

    data.bucket('govuk-release-app-test').object('postgresql_backend/release_app_data.tar').get(response_target: './response.txt')
  end


end


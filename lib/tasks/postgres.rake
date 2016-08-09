require 'yaml'

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


end


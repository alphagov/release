require "csv"
require "report/deploy_lag_report"

desc "Output a CSV report of deploy lags by app and month"
task deploy_lag: :environment do
  puts(CSV.generate do |csv|
    csv << %w[short_name timestamp version prod_deploy_timestamp prod_deploy_version]

    Report::DeployLagReport.new.call.each do |sequence|
      csv << [
        sequence[:app].shortname,
        sequence[:deploy].created_at,
        sequence[:deploy].version,
        sequence[:prod_deploy].created_at,
        sequence[:prod_deploy].version,
      ]
    end
  end)
end

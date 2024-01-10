desc "Posts a list of apps with out-of-sync deploys to the relevant team's Slack channel"
task post_out_of_sync_deploys: :environment do
  PostOutOfSyncDeploysJob.perform_later
end

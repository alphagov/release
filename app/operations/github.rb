class Github < Artemis::Client
  class QueryError < StandardError; end

  self.default_context = {
    headers: {
      Authorization: "Bearer #{ENV['GITHUB_ACCESS_TOKEN']}",
    },
  }
end

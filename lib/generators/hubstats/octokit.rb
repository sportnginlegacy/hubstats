if github_auth = Hubstats.config.github_auth
  Hubstats::GithubAPI.configure(github_auth)
end

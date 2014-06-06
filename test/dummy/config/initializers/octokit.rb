if Pathname("#{Rails.root}/config/octokit.yml").exist?
  Hubstats::GithubAPI.configure(YAML.load_file("#{Rails.root}/config/octokit.yml"))
end

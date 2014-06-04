if Pathname("#{Rails.root}/config/octokit.yml").exist?
  Hubification::GithubAPI.configure(YAML.load_file("#{Rails.root}/config/octokit.yml"))
end

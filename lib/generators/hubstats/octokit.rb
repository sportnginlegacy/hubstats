if Pathname("#{Rails.root}/config/octokit.yml").exist?
  octo = YAML.load_file("#{Rails.root}/config/octokit.yml").with_indifferent_access
  if (octo[:config].has_key?(:org_name) || octo[:config].has_key?(:repo_list))
    OCTOCONF = octo[:config]
  else
    raise "Must include repos or organization to watch"
  end

  Hubstats::GithubAPI.configure(octo[:auth])
end

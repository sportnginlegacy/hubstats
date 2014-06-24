module Hubstats
  class InstallGenerator < ::Rails::Generators::Base

    source_root File.expand_path('../', __FILE__)  
    def octokit_initializer
      copy_file "octokit.example.yml", "#{Rails.root}/config/octokit.yml"
      copy_file "octokit.rb", "#{Rails.root}/config/initializers/octokit.rb"
    end

  end
end
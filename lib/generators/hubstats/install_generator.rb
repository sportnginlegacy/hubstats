module Hubstats
  class InstallGenerator < ::Rails::Generators::Base

    # Copies the octokit.example.yml when 'rails generate hubstats:install' is run on the command line
    source_root File.expand_path('../', __FILE__)  
    def octokit_initializer
      copy_file "octokit.example.yml", "#{Rails.root}/config/octokit.yml"
    end

  end
end

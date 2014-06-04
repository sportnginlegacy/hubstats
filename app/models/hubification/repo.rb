module Hubification
  class Repo < ActiveRecord::Base
    attr_accessible :id, :name, :full_name, :private, :fork, :url, :html_url,
      :clone_url, :git_url, :ssh_url, :svn_url, :mirror_url, :homepage, :language,
      :forks_count, :stargazers_count, :watches_count, :size , :default_branch,
      :open_issues_count, :has_issues, :has_wiki, :has_downloads, :pushed_at, :created_at,
      :updated_at, :permissions #permissions is a hash {admin, push ,pull}

    validates :id, presence: true, uniqueness: true
    belongs_to :owner, :class_name => "User", :foreign_key => "id"

  end

end

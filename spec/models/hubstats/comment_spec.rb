require 'spec_helper'

module Hubstats
  describe Comment, :type => :model do
    it 'creates and returns a comment and user' do
      github_user = {
        :login => "elliothursh",
        :id => 10,
        :type => "User"
      }

      github_comment = {
        :user => github_user,
        :id => 100
      }

      comment = Hubstats::Comment.find_or_create_comment(github_comment)

      expect(comment.id).to eq(github_comment[:id])
      expect(comment.user_id).to eq(github_user[:id])
    end
  end
end

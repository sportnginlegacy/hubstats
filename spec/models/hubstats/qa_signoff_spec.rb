require 'spec_helper'

module Hubstats
  describe QaSignoff, :type => :model do
    it 'should create and return a QA Signoff' do
      signoff = QaSignoff.first_or_create(123, 456, 789)
      expect(signoff.user_id).to eq(789)
      expect(signoff.repo_id).to eq(123)
      expect(signoff.pull_request_id).to eq(456)
    end

    it 'should remove a signoff' do
      signoff = QaSignoff.first_or_create(123, 456, 789)
      expect(Hubstats::QaSignoff.where(pull_request_id: 456).count).to eq(1)
      QaSignoff.remove_signoff(123, 456)
      expect(Hubstats::QaSignoff.where(pull_request_id: 456)).to eq([])
    end
  end
end

class MakeQaIndexUnique < ActiveRecord::Migration
  def change
  	remove_index :hubstats_qa_signoffs, :pull_request_id
  	add_index :hubstats_qa_signoffs, :pull_request_id, :unique => true
  end
end

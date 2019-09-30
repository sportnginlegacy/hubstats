class AddQaSignoff < ActiveRecord::Migration[4.2]
  def change
    create_table :hubstats_qa_signoffs do |t|
      t.belongs_to :user
      t.belongs_to :repo
      t.belongs_to :pull_request
      t.string :label_name
    end

    add_index :hubstats_qa_signoffs, :user_id
    add_index :hubstats_qa_signoffs, :repo_id
    add_index :hubstats_qa_signoffs, :pull_request_id
  end
end

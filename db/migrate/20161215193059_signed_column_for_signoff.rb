class SignedColumnForSignoff < ActiveRecord::Migration
  def change
  	add_column :hubstats_qa_signoffs, :signed_at, :datetime
  end
end

class SignedColumnForSignoff < ActiveRecord::Migration[4.2.10]
  def change
  	add_column :hubstats_qa_signoffs, :signed_at, :datetime
  end
end

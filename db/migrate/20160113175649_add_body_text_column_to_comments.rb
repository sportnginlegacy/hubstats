class AddBodyTextColumnToComments < ActiveRecord::Migration[4.2]
  def change
  	add_column :hubstats_comments, :body_text, :text
  end
end

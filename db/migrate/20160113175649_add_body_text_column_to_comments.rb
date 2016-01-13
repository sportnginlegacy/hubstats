class AddBodyTextColumnToComments < ActiveRecord::Migration
  def change
  	add_column :hubstats_comments, :body_text, :text
  end
end

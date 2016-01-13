class RenameBodyToBodyString < ActiveRecord::Migration
  def change
  	rename_column :hubstats_comments, :body, :body_string
  end
end

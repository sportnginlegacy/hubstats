class RenameBodyTextToBody < ActiveRecord::Migration
  def change
  	rename_column :hubstats_comments, :body_text, :body
  end
end

class RenameBodyTextToBody < ActiveRecord::Migration[4.2.10]
  def change
  	rename_column :hubstats_comments, :body_text, :body
  end
end

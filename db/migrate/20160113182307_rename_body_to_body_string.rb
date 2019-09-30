class RenameBodyToBodyString < ActiveRecord::Migration['4.2.10']
  def change
  	rename_column :hubstats_comments, :body, :body_string
  end
end

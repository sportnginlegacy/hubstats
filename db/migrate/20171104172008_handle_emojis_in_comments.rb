class HandleEmojisInComments < ActiveRecord::Migration
  def change
      execute("ALTER TABLE hubstats_comments MODIFY body TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;")
      execute("set names 'utf8mb4';")
  end
end

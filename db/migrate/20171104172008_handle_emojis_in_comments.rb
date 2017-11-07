class HandleEmojisInComments < ActiveRecord::Migration
  def change

      # Set the body column to use 4-byte characters so that 4-byte UTF-8 chars, such as emojis, can be stored.
      change_column :hubstats_comments, :body, "TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

      # Set the connection to use a 4-byte encoding as well.
      execute("set names 'utf8mb4';")
  end
end

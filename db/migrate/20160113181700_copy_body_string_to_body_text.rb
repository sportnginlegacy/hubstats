class CopyBodyStringToBodyText < ActiveRecord::Migration
  def change
     Hubstats::Comment.update_all("body_text=body")
  end
end

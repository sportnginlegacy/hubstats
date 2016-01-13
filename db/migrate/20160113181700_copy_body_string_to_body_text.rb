class CopyBodyStringToBodyText < ActiveRecord::Migration
  def self.up
     Hubstats::Comment.update_all("body_text=body")
  end

  def self.down
  	Hubstats::Comment.update_all("body=body_text")
  end
end

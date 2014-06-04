class CreateHubificationComments < ActiveRecord::Migration
  def change
    create_table :hubification_comments do |t|

      t.timestamps
    end
  end
end

class AddSpaceIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :space_id, :integer
  end

  def self.down
    remove_column :users, :space_id
  end
end

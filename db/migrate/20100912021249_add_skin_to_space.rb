class AddSkinToSpace < ActiveRecord::Migration
  def self.up
    add_column :spaces, :skin, :string, :default => 'default'
  end

  def self.down
    remove_column :spaces, :skin
  end
end

class AddCertificationLevelToRoom < ActiveRecord::Migration
  def self.up
    add_column :rooms, :certification_level, :integer
  end

  def self.down
    remove_column :rooms, :certification_level
  end
end

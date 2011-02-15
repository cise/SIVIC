class RenameColumn < ActiveRecord::Migration
  def self.up
    rename_column :rooms, :type, :room_type
    rename_column :reservations, :type, :reservation_type
  end

  def self.down
    rename_column :rooms, :room_type, :type
    rename_column :reservations, :reservation_type, :type
  end
end

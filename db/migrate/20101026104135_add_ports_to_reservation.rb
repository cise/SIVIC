class AddPortsToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :ports, :integer
  end

  def self.down
    remove_column :reservations, :ports
  end
end

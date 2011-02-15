class AddEventIdToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :event_id, :integer
  end

  def self.down
    remove_column :reservations, :event_id
  end
end

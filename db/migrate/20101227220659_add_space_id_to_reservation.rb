class AddSpaceIdToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :space_id, :integer
  end

  def self.down
    remove_column :reservations, :space_id
  end
end

class AddCancelledByToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :cancelled_by, :integer
  end

  def self.down
    remove_column :reservations, :cancelled_by
  end
end

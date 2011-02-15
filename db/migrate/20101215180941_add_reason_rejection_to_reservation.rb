class AddReasonRejectionToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :reason_rejection, :string
  end

  def self.down
    remove_column :reservations, :reason_rejection
  end
end

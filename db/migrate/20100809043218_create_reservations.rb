class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.string :title
      t.text :description
      t.string :type, :default => "public"
      t.string :vc_service
      t.string :country
      t.integer :room_id
      t.boolean :aggrement
      t.string :state
      t.text :notes
      t.integer :user_id
      t.integer :admin_id
      t.boolean :allow_invitation
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end

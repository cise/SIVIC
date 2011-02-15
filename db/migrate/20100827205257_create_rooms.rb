class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string :name
      t.text :description
      t.string :country
      t.string :city
      t.text :location
      t.string :type
      t.string :service_type
      t.string :ip_address
      t.string :uri
      t.decimal :lng, :precision => 10, :scale => 8
      t.decimal :lat, :precision => 10, :scale => 8
      t.integer :user_id
      t.integer :space_id

      t.timestamps
    end
  end

  def self.down
    drop_table :rooms
  end
end

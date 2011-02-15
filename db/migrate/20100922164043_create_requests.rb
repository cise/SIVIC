class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :reservation_id
      t.text :message
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end

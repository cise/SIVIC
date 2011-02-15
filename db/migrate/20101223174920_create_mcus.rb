class CreateMcus < ActiveRecord::Migration
  def self.up
    create_table :mcus do |t|
      t.string :ip_address
      t.integer :mcunumber
      t.string :model
      t.string :trade
      t.integer :total_ports
      t.integer :shared_ports
      t.integer :space_id

      t.timestamps
    end
  end

  def self.down
    drop_table :mcus
  end
end

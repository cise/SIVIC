class AddDataToRoom < ActiveRecord::Migration
  def self.up
    add_column :rooms, :department, :string
    add_column :rooms, :phone_number, :string
    add_column :rooms, :capacity, :string
    add_column :rooms, :equipment, :text
    add_column :rooms, :devices, :text
    add_column :rooms, :light_type, :string
    add_column :rooms, :bandwidth, :string
    add_column :rooms, :reevaluation, :boolean
  end

  def self.down
    remove_column :rooms, :bandwidth
    remove_column :rooms, :light_type
    remove_column :rooms, :devices
    remove_column :rooms, :equipment
    remove_column :rooms, :capacity
    remove_column :rooms, :phone_number
    remove_column :rooms, :department
    remove_column :rooms, :reevaluation
  end
end

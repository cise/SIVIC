class AddStatusToPerformance < ActiveRecord::Migration
  def self.up
    add_column :performances, :status, :boolean, :default => true
  end

  def self.down
    remove_column :performances, :status
  end
end

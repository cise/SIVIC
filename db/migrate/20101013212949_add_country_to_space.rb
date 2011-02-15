class AddCountryToSpace < ActiveRecord::Migration
  def self.up
    add_column :spaces, :country, :string
  end

  def self.down
    remove_column :spaces, :country
  end
end

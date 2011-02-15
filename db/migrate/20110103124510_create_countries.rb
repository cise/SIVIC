class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.integer :id
      t.string :code
      t.string :name
      t.string :timezone
      t.string :gmt_offset

      t.timestamps
    end

    Country.delete_all
    
    Country.create :code => "AR", :name => "Argentina", :timezone => "Buenos Aires", :gmt_offset => "-0300"
    Country.create :code => "BO", :name => "Bolivia", :timezone => "La Paz", :gmt_offset => "-0400"
    Country.create :code => "BR", :name => "Brasil", :timezone => "Brasilia", :gmt_offset => "-0300"
    Country.create :code => "CL", :name => "Chile", :timezone => "Santiago", :gmt_offset => "-0400"
    Country.create :code => "CO", :name => "Colombia", :timezone => "Bogota", :gmt_offset => "-0500"
    Country.create :code => "CR", :name => "Costa Rica", :timezone => "Central America", :gmt_offset => "-0600"
    Country.create :code => "EC", :name => "Ecuador", :timezone => "Quito", :gmt_offset => "-0500"
    Country.create :code => "SV", :name => "El Salvador", :timezone => "Central America", :gmt_offset => "-0600"
    Country.create :code => "ES", :name => "España", :timezone => "Madrid", :gmt_offset => "+0100"
    Country.create :code => "GT", :name => "Guatemala", :timezone => "Central America", :gmt_offset => "-0600"
    Country.create :code => "MX", :name => "México", :timezone => "Mexico City", :gmt_offset => "-0600"
    Country.create :code => "PA", :name => "Panamá", :timezone => "Eastern Time (US & Canada)", :gmt_offset => "-0500"
    Country.create :code => "PE", :name => "Perú", :timezone => "Lima", :gmt_offset => "-0500"
    Country.create :code => "UY", :name => "Uruguay", :timezone => "Buenos Aires", :gmt_offset => "-0300"
    Country.create :code => "VE", :name => "Venezuela", :timezone => "Caracas", :gmt_offset => "-0430"
    
  end

  def self.down
    drop_table :countries
  end
end

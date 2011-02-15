class Mcu < ActiveRecord::Base
  belongs_to :space
  
  validates_presence_of :ip_address, :message => :"ip_address.blank"
  validates_format_of :ip_address, :with => /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/, :message => :"ip_address.valida"
  validates_presence_of	:mcunumber, :message => :"mcunumber.blank"
  validates_presence_of	:model, :message => :"model.blank"
  validates_presence_of	:trade, :message => :"trade.blank"
  validates_presence_of	:total_ports , :message => :"total_ports.blank"
  validates_presence_of	:shared_ports, :message => :"shared_ports.blank"
  
  def self.total_ports(space)
    self.connection.select_all("SELECT COUNT total_ports as total FROM mcus WHERE space_id = #{space.id};")
  end
end

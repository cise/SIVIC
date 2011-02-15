class Country < ActiveRecord::Base
	validates_presence_of :code, :message => :"code.blank"
	validates_presence_of :name, :message => :"name.blank"
	validates_presence_of :timezone, :message => :"timezone.blank"

  def self.getCountries(spaces)
    find(:all, :select => "DISTINCT name, code", :conditions => ["code in (?)", spaces.collect {|s| s.country}], :order => "name", :readonly => true).map { |x| [x.name, x.code] }
  end
end

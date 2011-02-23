class Room < ActiveRecord::Base
  
  SERVICE_TYPE_CERTIFIED = "Certificada"
  SERVICE_TYPE_EVALUATION = "En Evaluacion"
  SERVICE_TYPE_INITIATION = "En iniciacion"
  SERVICE_TYPE_NOT_CERTIFIED = "Pendiente por evaluacion"

  SERVICE_TYPE_VIRTUAL = "Virtual"

  SERVICE_TYPES = [
    SERVICE_TYPE_CERTIFIED,
    SERVICE_TYPE_EVALUATION,
    SERVICE_TYPE_INITIATION,
    SERVICE_TYPE_NOT_CERTIFIED
  ]

  CERTIFICATION_LEVELS = [
    [I18n.t("room.certification_levels.label.level_5"), 5], 
    [I18n.t("room.certification_levels.label.level_4"), 4], 
    [I18n.t("room.certification_levels.label.level_3"), 3], 
    [I18n.t("room.certification_levels.label.level_2"), 2], 
    [I18n.t("room.certification_levels.label.level_1"), 1]
  ]

  # added for SAR
  belongs_to :space
  has_many :reservations
  has_many :calendar_events, :as => :object

  attr_accessor :bandera_mail

  acts_as_resource 
#  acts_as_content :reflection => :space
#  acts_as_container :contents => [ :reservations ]
  acts_as_stage
  
  validates_presence_of :name, :message => :"name.blank"
  validates_presence_of :description, :message => :"description.blank"
  
  # Implement params_from_atom for AtomPub support
  # Return hash with content attributes
  def self.params_from_atom(entry)
    # Example:
    # { :body => entry.content.xml.to_s }
    {}
  end
  
  def self.getCountries
    find(:all, :select => "DISTINCT(country)", :order => "country", :readonly => true)
  end

  def self.getCountriesBySpaces(spaces)
    find(:all, :select => "DISTINCT(country)", :conditions => ["country IS NOT NULL AND space_id IN (?)", spaces], :order => "country", :readonly => true)
  end

  def self.getManagedRooms(user)
    #user.agent_performances.select {|x| x.role.name == 'VNOC'}.map {|y| y.stage_id }
    user.stages(:type => 'Room')
  end

  def self.available_rooms(spaces, new_calendar_events)
    find(:all, :conditions => ["space_id in (?)", spaces.collect {|s| s.id}]).select {|r| r.available(new_calendar_events)}
  end

  def self.room_virtual
    find(:first, :conditions => ["room_type = ?", Room::SERVICE_TYPE_VIRTUAL])
  end

  def available(new_calendar_events)
    logger.error "room= #{id}"

    for new_calendar_event in new_calendar_events
      logger.error "new_calendar_event=#{new_calendar_event.id} allday=#{new_calendar_event.all_day} 
        starttime=#{new_calendar_event.starttime} endtime= #{new_calendar_event.endtime}"
      for room_event in calendar_events.select {|e| e.in(new_calendar_event) || new_calendar_event.in(e) }
        logger.error "room_event=#{room_event.id} starttime=#{room_event.starttime} endtime= #{room_event.endtime}"
        return false
      end

      reservations_approved = reservations.select {|r| r.state == Reservation::STATE_APPROVED}
      logger.error "reservations_approved=#{reservations_approved.size}"

      if reservations_approved.size > 0 
        for room_reservation in reservations_approved 
          logger.error "reservation=#{room_reservation.id}"
          for room_reservation_event in room_reservation.calendar_events.select {|e| e.id != new_calendar_event.id && 
                                                                                (e.in(new_calendar_event) || new_calendar_event.in(e)) }
            logger.error "room_reservation_event=#{room_reservation_event.id} all_day=#{room_reservation_event.all_day} starttime=#{room_reservation_event.starttime} endtime=#{room_reservation_event.endtime}"
            return false
          end
        end
      end
    end
    return true
  end  

  def cancel_reservations(reservation)
    reservations_pending = reservations.select{|r| r.state == Reservation::STATE_PENDING}
    logger.error "reservations_pending=#{reservations_pending.size}"

    if reservations_pending.size > 0 
      for room_reservation in reservations_pending
        logger.error "reservation=#{room_reservation.id}"
        for new_calendar_event in reservation.calendar_events.sort {|c,d| c.starttime <=> d.starttime}
          logger.error "calendar_event starttime=#{new_calendar_event.starttime} endtime=#{new_calendar_event.endtime}"
          for room_reservation_event in room_reservation.calendar_events.select {|e| e.id != new_calendar_event.id && (e.in(new_calendar_event) || new_calendar_event.in(e)) }
            logger.error "room_reservation_event=#{room_reservation_event.id} all_day=#{room_reservation_event.all_day} starttime=#{room_reservation_event.starttime} endtime=#{room_reservation_event.endtime}"
            room_reservation.state = Reservation::STATE_REJECTED
            room_reservation.admin_id = reservation.admin_id
            room_reservation.notes = "Rechazada automaticamente."
            room_reservation.save(false)
            logger.error "room_reservation.state = #{room_reservation.state}"
          end
        end
      end
    end

  end

  def users_by_role(role)
    stage_performances.select {|x| x.role.name == role}.collect {|y| y.agent }
  end

  def performances_by_role(role)
    stage_performances.select {|x| x.role.name == role}
  end
  
  def certification_level_stars
    certification_level ? I18n.t("room.certification_levels.level_#{certification_level}") : ""
  end

  def certification_level_text
    certification_level ? I18n.t("room.certification_levels.label.level_#{certification_level}") : "No asignado"
  end

  def name_certification_level_starts
    space.name + ", " + name + " " + certification_level_stars
  end

  def name_certification_level
    space.name + ", " + name + " " + certification_level_text
  end

  def full_location
    fl = "#{country}"
    fl = (!fl.nil? && fl != "" ? "#{city}, " : city) + fl
    fl = (!fl.nil? && fl != "" ? "#{location}. " : location) + fl 
logger.error "full_location=#{fl}"
  end

  after_update do |room|
    if(room.bandera_mail)
      vnoc = User.find(:first, :conditions => ["login = 'vnoc'"])
      Informer.deliver_room_update(room, vnoc)
    end		 
  end
  
  after_create do |room|
    vnoc = User.find(:first, :conditions => ["login = 'vnoc'"])
    Informer.deliver_room_create(room, vnoc)
  end
end

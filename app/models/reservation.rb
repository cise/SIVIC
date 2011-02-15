class Reservation < ActiveRecord::Base
  STATE_PENDING = "Pendiente"
  STATE_APPROVED = "Aprobada"
  STATE_REJECTED = "Rechazada"
  STATE_DELETED = "Cancelada"

  STATE_TYPES = [STATE_PENDING, STATE_APPROVED, STATE_REJECTED]

  REJECT_REASONS = [
    [:technical_problems, "Problemas técnicos"], 
    [:logistic_problems, "Problemas Logisiticos"], 
    [:room_under_maintenance, "Sala en mantenimiento"], 
    [:others, "Otros"]
  ]
  
  ACTION_APPROVE = "aprobar"
  ACTION_REJECT = "rechazar"
  
  ACTION_ACCEPT_INVITATION = "aceptar"
  ACTION_DECLINE_INVITATION = "declinar"
  
  ACTION_ACCEPT= "reservar"
  ACTION_CANCEL= "cancelar"

  belongs_to :room
  belongs_to :user
  belongs_to :event
  belongs_to :space

  has_many :calendar_events, :as => :object
  has_many :requests
  
  has_many :childs, :class_name => "Reservation", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Reservation"

  acts_as_resource :per_page => 10
  acts_as_content :reflection => :space

   #ivan
  attr_accessor :id_invitacion
  attr_accessor :horario
  attr_accessor :participante
   #ivan
  
  #acts_as_content :reflection => :room
  
  validates_presence_of :horario,:message => :"horario.blank", :on => :create
  validates_presence_of :participante,:message => :"participante.blank", :on => :create
  validates_presence_of :title, :message => :"title.blank"
  validates_presence_of	:description, :message => :"description.blank"
  validates_length_of   :description, :within => 100..10000, :message => :"description.length"
  validates_presence_of :room_id, :message => :"room.blank"
  validates_presence_of :aggrement, :message => :"aggrement.blank"
  validates_presence_of :ports, :if => :is_private?, :message => :"ports.blank"

  def self.owner(user)
    Reservation.find(:all, :conditions => ["state IN (?) and user_id = ?", [self::STATE_APPROVED, self::STATE_REJECTED], user.id], :order => 'updated_at DESC')
  end

  def self.owner_or_invited(user)
    Reservation.find(:all, :conditions => ["user_id = ? AND (state IN (?) OR (state = ? AND parent_id IS NOT NULL))", user.id, [self::STATE_APPROVED, self::STATE_REJECTED], self::STATE_PENDING], :order => 'updated_at DESC')
  end

  def self.pending_(user)
    Reservation.find(:all, :conditions => ["state = ? and room_id IN (?)", self::STATE_PENDING, Room.getManagedRooms(user)], :order => 'updated_at DESC')
  end

  def self.pending(user)
    Reservation.find(:all, :conditions => ["state = ? and (room_id IN (?) or user_id = ?)", self::STATE_PENDING, Room.getManagedRooms(user), user.id], :order => 'updated_at DESC')
  end

#  def complete
#    complete = true
#    parent.childs.each do |child|
#      complete = complete && child.state == STATE_APPROVED
#    end
#  end
    
# Author Permissions
#  authorizing do |agent, permission|
#    if user == agent &&
#        ( permission == :update || permission == :delete ) &&
#        room.authorize?([ :create, :content ], :to => agent)
#      true
#    end
#  end
  after_create do |reservation|
    if reservation.vc_service == Room::SERVICE_TYPE_VIRTUAL
      # Notificar al VNOC solicitando puertos MCU
      vnoc = User.find(:first, :conditions => ["login = 'vnoc'"])
      Informer.deliver_reservation_virtual_request_notification(reservation, vnoc)
    else
      # Notificar a los COVI de la sala solicitada
      admins = reservation.room.users_by_role("COVI")
      for admin in admins do
        Informer.deliver_reservation_request_notification(reservation, admin)
      end
    end
  end

  after_update do |reservation|
    if reservation.state == STATE_APPROVED || reservation.state == STATE_REJECTED
      Informer.deliver_reservation_processed_notification(reservation, reservation.user)
    elsif reservation.state == STATE_DELETED
      if reservation.event_id?
        if reservation.room.users_by_role("COVI").include?(User.find(reservation.cancelled_by))
          Informer.deliver_reservation_cancelled_by_covi_notification(reservation, reservation.user)
        else
          Informer.deliver_reservation_cancelled_by_user_notification(reservation, User.find(reservation.admin_id))
        end

        for request in reservation.requests do
          if reservation.room.users_by_role("COVI").include?(User.find(reservation.cancelled_by))
            Informer.deliver_reservation_cancelled_by_covi_notification(reservation, User.find(request.recipient_id)) if request.status != Request::STATUS_WAITING
          else
            Informer.deliver_reservation_cancelled_notification(reservation, User.find(request.recipient_id)) if request.status != Request::STATUS_WAITING
          end
        end      
      else
        if reservation.admin_id?
          Informer.deliver_reservation_cancelled_notification(reservation, User.find(reservation.admin_id))
        else
          # Notificar a los COVI de la sala solicitada
          admins = reservation.room.users_by_role("COVI")
          for admin in admins do
            Informer.deliver_reservation_cancelled_notification(reservation, admin)
          end
        end
      end
    end
  end

  def reason_rejection_text
    Reservation::REJECT_REASONS.assoc(reason_rejection.to_sym).at(1)
  end

  def is_private?
    return vc_service == Room::SERVICE_TYPE_VIRTUAL
  end

  def delete_cascade
    if !calendar_events.nil?
      for calendar_event in calendar_events
        calendar_event.destroy
      end
    end

    if !requests.nil?
      for request in requests
        request.status = Request::STATUS_DELETED
        request.save
      end
    end
  end

end

class Request < ActiveRecord::Base
  STATUS_WAITING = "En Espera"
  STATUS_PENDING = "Pendiente"
  STATUS_ACCEPTED = "Aceptada"
  STATUS_DECLINED = "Declinada"
  STATUS_DELETED = "Eliminada"

  belongs_to :reservation

  acts_as_resource :per_page => 10
  
  validates_presence_of :reservation_id, :message => :"title.blank"

  def self.pending(user)
    Request.find(:all, :conditions => ["status = ? and recipient_id = ?", self::STATUS_PENDING, user.id], :order => 'updated_at DESC')
  end

  after_update do |request|
    if request.status == STATUS_PENDING
      #Informer.deliver_request_reservation_notification(request, User.find(request.recipient_id))
    elsif request.status == STATUS_ACCEPTED || request.status == STATUS_DECLINED
      Informer.deliver_request_processed_notification(request, User.find(request.sender_id))
    end    
  end
end

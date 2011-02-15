# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

#This class will compose all the mails that the application should send

class PrivateSender
  
  def self.invitation_message(invitation)
    m = PrivateMessage.new :title => I18n.t("invitation.to_space",:space=>invitation.group.name,:username=>invitation.introducer.full_name),
      :body => invitation.comment.gsub('\'' + I18n.t('name.one') + '\'',invitation.candidate.full_name).gsub('\'' + I18n.t('url_plain') + '\'', "<a href=\"http://" + Site.current.domain + "/invitations/" + invitation.code + "\">http://" + Site.current.domain + "/invitations/" + invitation.code + "</a>")
    m.receiver = invitation.candidate
    m.save!
  end
  
  
  def self.event_invitation_message(invitation)
    m = PrivateMessage.new :title => I18n.t("invitation.to_event",:eventname=>invitation.group.name,:space=>invitation.group.space.name,:username=>invitation.introducer.full_name),
      :body => invitation.comment.gsub('\'' + I18n.t('name.one') + '\'',invitation.candidate.full_name).gsub('\'' + I18n.t('url_plain') + '\'', "<a href=\"http://" + Site.current.domain + "/invitations/" + invitation.code + "\">http://" + Site.current.domain + "/invitations/" + invitation.code + "</a>")
    m.receiver = invitation.candidate
    m.save!
  end

  
  def self.event_notification_message(event,receiver)
    m = PrivateMessage.new :title => I18n.t("event.notification.subject",:eventname=>event.name,:space=>event.space.name,:username=>(User.find(event.notif_sender_id)).full_name),
      :body => ( event.notify_msg.gsub('\'' + I18n.t('name.one') + '\'',receiver.full_name) + "<br/><br/>" )
    m.receiver = receiver
    m.save!
  end
  
  
  def self.join_request_message(jr,receiver)
    m = PrivateMessage.new :title => I18n.t("join_request.ask_subject", :candidate => jr.candidate.name, :space => jr.group.name),
      :body => jr.comment
    m.receiver = receiver
    m.save!
  end
  
  
  def self.processed_invitation_message(invitation, receiver)
    action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")
    
    if invitation.candidate != nil
      m = PrivateMessage.new :title => I18n.t("e-mail.invitation_result.admin_side",:name=>invitation.candidate.name, :action => action, :spacename =>invitation.group.name),
        :body => "<p>" + invitation.introducer.full_name + ",</p>" +
          "<p>" + I18n.t('e-mail.invitation_result.admin_side',:name=>invitation.candidate.full_name, :action => action, :spacename =>invitation.group.name) + ".</p>" +
          "<p>" + I18n.t('invitation.info_users', :users_url => "http://" + Site.current.domain + "/spaces/" + invitation.group.permalink + "/users") + "</p>" +
          "<p>" + Site.current.signature_in_html + "</p>"
    else
      m = PrivateMessage.new :title => I18n.t("e-mail.invitation_result.admin_side",:name=>invitation.email, :action => action, :spacename =>invitation.group.name),
        :body => "<p>" + invitation.introducer.full_name + ",</p>" +
          "<p>" + I18n.t('e-mail.invitation_result.admin_side',:name=>invitation.email[0,invitation.email.index('@')], :action => action, :spacename =>invitation.group.name) + ".</p>" +
          "<p>" + I18n.t('invitation.info_users', :users_url => "http://" + Site.current.domain + "/spaces/" + invitation.group.permalink + "/users") + "</p>" +
          "<p>" + Site.current.signature_in_html + "</p>" 
    end

    m.receiver = receiver
    m.save!
  end
  
  
  def self.processed_join_request_message(jr)
    action = jr.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")
    
    if jr.accepted?
      m = PrivateMessage.new :title => I18n.t("e-mail.invitation_result.user_side", :action => action, :spacename =>jr.group.name),
      :body => I18n.t('e-mail.invitation_result.user_side', :action => action, :spacename =>jr.group.name) + "<br/><br/>" +
        I18n.t('invitation.access_space', :spacename => jr.group.name, :space_url => "http://" + Site.current.domain + "/spaces/" + jr.group.permalink) + "<br/><br/>" +
        I18n.t('admin.space', :spacename => jr.group.name)
    else
      m = PrivateMessage.new :title => I18n.t("e-mail.invitation_result.user_side", :action => action, :spacename =>jr.group.name),
      :body => I18n.t('e-mail.invitation_result.user_side', :action => action, :spacename =>jr.group.name) + "<br/><br/>" +
        I18n.t('invitation.rejoin_space', :space_url => "http://" + Site.current.domain + "/spaces/" + jr.group.permalink + "/join_requests/new") + "<br/><br/>" +
        I18n.t('admin.space', :spacename => jr.group.name)
    end
     
    m.receiver = jr.candidate
    m.save!
  end
  
  def self.reservation_request_notification_message(reservation, receiver)
    room = reservation.room
    m = PrivateMessage.new :title => I18n.t("reservation.notification.subject", :eventname => reservation.title,
      :space => room.space.name, :username => User.find(reservation.user_id).full_name, :room => room.name), 
      :body => I18n.t("reservation.notification.body", :eventname => reservation.title,
    :space => room.space.name, :username => User.find(reservation.user_id).full_name, :room => room.name)
    m.receiver = receiver
    m.save!
  end

  def self.reservation_virtual_request_notification_message(reservation, receiver)
    room = reservation.room
    m = PrivateMessage.new :title => I18n.t("reservation.notification.virtual.subject", 
        :eventname => reservation.title, :space => room.space.name,
        :username => User.find(reservation.user_id).full_name, :room => room.name
      ), :body => I18n.t("reservation.notification.virtual.body", 
        :eventname => reservation.title, :ports => reservation.ports, :space => room.space.name, 
        :username=> User.find(reservation.user_id).full_name, :room => room.name
      )
    m.receiver = receiver
    m.save!
  end

  def self.reservation_cancelled_notification_message(reservation, receiver)
    room = reservation.room
    m = PrivateMessage.new :title => I18n.t("reservation.notification.cancelled.subject", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.user_id).full_name, :room => room.name, :action => reservation.state
      ), :body => I18n.t("reservation.notification.cancelled.body", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.user_id).full_name, :room => room.name, :action => reservation.state
      )
    m.receiver = receiver
    m.save!
  end

  def self.reservation_processed_notification_message(reservation, receiver)
    room = reservation.room
    m = PrivateMessage.new :title => I18n.t("reservation.notification.processed.subject", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.admin_id).full_name, :room => room.name, :action => reservation.state
      ), :body => I18n.t("reservation.notification.processed.body", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.admin_id).full_name, :room => room.name, :action => reservation.state
      ) + @reservation.state == Reservation::STATE_APPROVED ? I18n.t("reservation.notification.processed.room_info", :covi_name => @user_sender.full_name, :room_location => @room.full_location, :room_phonenumber => @room.phone_number) : ""
      + @reservation.notes ? I18n.t('reservation.notification.processed.covi_notes', :covi_notes => @reservation.notes) : ""
    m.receiver = receiver
    m.save!
  end
  
  def self.request_reservation_notification_message(request, receiver)
    reservation = request.reservation
    m = PrivateMessage.new :title => I18n.t("reservation.notification.request.subject", 
        :eventname => reservation.title, :username => User.find(request.sender_id).full_name, 
        :schedule => reservation.calendar_events.join(", ")
      ), :body => I18n.t("reservation.notification.request.body", 
        :eventname => reservation.title, :username => User.find(request.sender_id).full_name, 
        :schedule => reservation.calendar_events.join(", ")
      )
    m.receiver = receiver
    m.save!
  end
  
  def self.request_processed_notification_message(request, receiver)
    reservation = request.reservation
    m = PrivateMessage.new :title => I18n.t("reservation.notification.request.processed.subject", 
        :eventname => reservation.title, :username => User.find(request.recipient_id).full_name, 
        :schedule => reservation.calendar_events.join(", "), :action => request.status
      ), :body => I18n.t("reservation.notification.request.processed.body", 
        :eventname => reservation.title, :username => User.find(request.recipient_id).full_name, 
        :schedule => reservation.calendar_events.join(", "), :action => request.status
      )
    m.receiver = receiver
    m.save!
  end
 def self.room_update_message(request, receiver)
    room = request.room
    m = PrivateMessage.new :title => I18n.t("room.notification.subject", 
        :room => room.name, 
		:username => User.find(request.recipient_id).full_name), 
		:body => I18n.t("room.notification.body", 
        :room => room.name,
		:username => User.find(request.recipient_id).full_name, 
        :space =>Space.find(room.space_id).name),
		:footer => I18n.t("room.notification.footer", 
        :url => "http://" + Site.current.domain + "/manage/edit_room/" + room.id)
    m.receiver = receiver
    m.save!
  end
  def self.room_create_message(request, receiver)
    room = request.room
    m = PrivateMessage.new :title => I18n.t("room.notification.subject", 
        :room => room.name, 
		:username => User.find(request.recipient_id).full_name), 
		:body => I18n.t("room.notification.body", 
        :room => room.name,
		:username => User.find(request.recipient_id).full_name, 
        :space =>Space.find(room.space_id).name),
		:footer => I18n.t("room.notification.footer", 
        :url => "http://" + Site.current.domain + "/manage/edit_room/" + room.id)
    m.receiver = receiver
    m.save!
  end

  def self.reservation_cancelled_by_covi_notification_message(reservation, receiver)
    room = reservation.room
    available_rooms = Room.available_rooms(receiver.spaces, reservation.calendar_events)
    m = PrivateMessage.new :title => I18n.t("reservation.notification.cancelled.subject", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.cancelled_by).full_name, :room => room.name, :action => reservation.state
      ), :body => I18n.t("reservation.notification.cancelled.body", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.cancelled_by).full_name, :room => room.name, :action => reservation.state
      ) + I18n.t("reservation.notification.cancelled.reasons", :reasons => reservation.reason_rejection_text) 
        + (available_rooms.size > 0 ? 
             I18n.t("reservation.notification.cancelled.available_rooms", :available_rooms => available_rooms.map{|r| r.name }.join(', ')) :
             I18n.t("reservation.notification.cancelled.no_available_rooms"))
    m.receiver = receiver
    m.save!
  end

  def self.reservation_cancelled_by_user_notification_message(reservation, receiver)
    room = reservation.room
    m = PrivateMessage.new :title => I18n.t("reservation.notification.cancelled.subject", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.cancelled_by).full_name, :room => room.name, :action => reservation.state
      ), :body => I18n.t("reservation.notification.cancelled.body", 
        :eventname => reservation.title, :space => room.space.name, 
        :username => User.find(reservation.cancelled_by).full_name, :room => room.name, :action => reservation.state
      ) + I18n.t("reservation.notification.cancelled.reasons", :reasons => reservation.reason_rejection) 
    m.receiver = receiver
    m.save!
  end
  def self.reservation_invitation_notification_message(request, receiver)
    request_aux = request.request
	reservation= Reservation.find(request_aux.reservation_id)
    if request.status == Request::STATUS_ACCEPTED
		estado_aux = "Aceptado"
	elsif request.status == Reservation::ACTION_DECLINE_INVITATION
		estado_aux = "Rechazo"
	end
	m = PrivateMessage.new :title => I18n.t("room.invitation.subject", 
        :username => User.find(request_aux.recipient_id).full_name,
		:reservation =>reservation.title),
		:body => I18n.t("room.invitation.body", 
		:username => User.find(request_aux.recipient_id).full_name, 
        :reservation =>reservation.title,
		:estado => estado_aux)
    m.receiver = receiver
    m.save!
  end
end

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
class Notifier < ActionMailer::Base
  
  def invitation_email(invitation)
    setup_email(invitation.email)

    @subject += I18n.t("invitation.to_space",:space=>invitation.group.name,:username=>invitation.introducer.full_name)
    @body[:invitation] = invitation
    @body[:space] = invitation.group    
    @body[:space_logo] = invitation.group.parent ? invitation.group : nil
    @body[:user] = invitation.introducer
    if invitation.candidate
      @body[:name] = invitation.candidate.full_name
    else
      @body[:name] = invitation.email[0,invitation.email.index('@')]
    end
    @headers.store("Reply-To",invitation.introducer.email)
  end


  def event_invitation_email(invitation)
    setup_email(invitation.email)

    @subject += I18n.t("invitation.to_event",:eventname=>invitation.group.name,:space=>invitation.group.space.name,:username=>invitation.introducer.full_name)
    @body[:invitation] = invitation
    @body[:space] = invitation.group.space    
    @body[:space_logo] = invitation.group.space.parent ? invitation.group.space : nil
    @body[:event] = invitation.group
    @body[:user] = invitation.introducer
    @headers.store("Reply-To",invitation.introducer.email)
  end
  
  def event_notification_email(event,receiver)
    setup_email(receiver.email)

    user_sender = User.find(event.notif_sender_id)
    @subject += I18n.t("event.notification.subject",:eventname=>event.name,:space=>event.space.name,:username=>user_sender.full_name)
    @body[:event] = event
    @body[:space_logo] = event.space.parent ? event.space : nil
    @body[:receiver] = receiver
    @headers.store("Reply-To",user_sender.email)
  end

  def space_group_invitation_email(space,mail)
    setup_email(mail)

    user_sender = User.find(space.group_inv_sender_id)
    @subject += I18n.t("space.group_invitation.subject",:space=>space.name,:username=>user_sender.full_name)
    @body[:space] = space
    @body[:space_logo] = space
    @headers.store("Reply-To",user_sender.email)
  end

  def event_group_invitation_email(event,mail)
    setup_email(mail)

    user_sender = User.find(event.group_inv_sender_id)
    @subject += I18n.t("event.group_invitation.subject",:eventname=>event.name,:space=>event.space.name,:username=>user_sender.full_name)
    @body[:event] = event
    @body[:space_logo] = event.space
    @headers.store("Reply-To",user_sender.email)
  end

  def processed_invitation_email(invitation, receiver)
    setup_email(receiver.email)
	
    action = invitation.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")
    if invitation.candidate != nil
      @subject += I18n.t("e-mail.invitation_result.admin_side",:name=>invitation.candidate.name, :action => action, :spacename =>invitation.group.name)
    else
      @subject += I18n.t("e-mail.invitation_result.admin_side",:name=>invitation.email, :action => action, :spacename =>invitation.group.name)
    end
    @body[:invitation] = invitation
    @body[:space] = invitation.group
    @body[:space_logo] = invitation.group
    @body[:signature]  = Site.current.signature_in_html
    @body[:action] = action
    @headers.store("Reply-To",invitation.email)
  end

  def join_request_email(jr,receiver)
    setup_email(receiver.email)

    @subject += I18n.t("join_request.ask_subject", :candidate => jr.candidate.name, :space => jr.group.name)	
    @body[:join_request] = jr
    @body[:space_logo] = jr.group
    @body ["contact_email"] = Site.current.email
    @body[:signature]  = Site.current.signature_in_html
    @headers.store("Reply-To",jr.candidate.email)
  end

  def processed_join_request_email(jr)
    setup_email(jr.candidate.email)
	
    action = jr.accepted? ? I18n.t("invitation.yes_accepted") : I18n.t("invitation.not_accepted")
    @subject += I18n.t("e-mail.invitation_result.user_side", :action => action, :spacename =>jr.group.name)	
    @body[:jr] = jr
    @body[:space_logo] = jr.group
    @body[:space] = jr.group
    @body[:action] = action
  end

  #This is used when an user registers in the application, in order to confirm his registration 
  def confirmation_email(user)
    setup_email(user.email)

    @subject += I18n.t("e-mail.welcome",:sitename=>Site.current.name)
	if user.superuser || user.space_id == nil
       	if user.main_space!= nil
	       	@body[:space_logo] = user.main_space
	       else
			@body[:space_logo] = nil
	       end
       else
		@body[:space_logo] = Space.find(user.space_id)
       end
    @body["name"] = user.full_name
    @body["hash"] = user.activation_code
    @body ["contact_email"] = Site.current.email
    @body[:signature]  = Site.current.signature_in_html	
  end

  def activation(user)
    setup_email(user.email)

    @subject += I18n.t("account_activated", :sitename=>Site.current.name)
    @body[:user] = user
	if user.superuser || user.space_id == nil
       	if user.main_space!= nil
	       	@body[:space_logo] = user.main_space
	       else
			@body[:space_logo] = nil
	       end
       else
		@body[:space_logo] = Space.find(user.space_id)
       end
    @body ["contact_email"] = Site.current.email
    @body[:url]  = "http://" + Site.current.domain + "/"
    @body[:sitename]  = Site.current.name
    @body[:signature]  = Site.current.signature_in_html	
  end
  
  #This is used when a user asks for his password.
  def lost_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.request", :sitename=>Site.current.name)   
	if user.superuser || user.space_id == nil
       if user.main_space!= nil
	       	@body[:space_logo] = user.main_space
	       else
			@body[:space_logo] = nil
	       end
       else
	@body[:space_logo] = Space.find(user.space_id)
       end
    @body ["name"] = user.full_name
    @body ["contact_email"] = Site.current.email
    @body["url"]  = "http://#{Site.current.domain}/reset_password/#{user.reset_password_code}" 
    @body[:signature]  = Site.current.signature_in_html		
  end

  #this method is used when a user has asked for his old password, and then he resets it.
  def reset_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.reset_email", :sitename=>Site.current.name)
	if user.superuser || user.space_id == nil
            if user.main_space!= nil
	       @body[:space_logo] = user.main_space
	     else
			@body[:space_logo] = nil
	       end
       else
	@body[:space_logo] = Space.find(user.space_id)
       end
    @body[:sitename]  = Site.current.name	
   	@body[:signature]  = Site.current.signature_in_html		
  end
  
  #this method is used when a user has sent feedback to the admin.
  def feedback_email(email, subject, body)
    setup_email(Site.current.email)
    
    @from = email
    @subject += I18n.t("feedback.one") + " " + subject
    @body ["text"] = body
    @body ["user"] = email
  end
  
  #this method is used when a user has sent feedback to the admin.
  def spam_email(user,subject, body)
    setup_email(Site.current.email)
    
    @from = user.email
    @subject += subject
	if user.superuser || user.space_id == nil
	     if user.main_space!= nil
	           @body[:space_logo] = user.main_space
	     else
		    @body[:space_logo] = nil
            end
       else
	@body[:space_logo] = Space.find(user.space_id)
       end
    @body ["text"] = body
    @body ["user"] = user.full_name
    @body[:sitename]  = Site.current.name
    @body[:signature]  = Site.current.signature_in_html		
  end

  def private_message_notification(private_message, receiver)
    setup_email(receiver.email)

    user_sender = User.find(private_message.sender_id)

    @subject += I18n.t("private_message.notification.subject", :username => user_sender.full_name)
    @body[:text] = I18n.t("private_message.notification.body", :user_sender => user_sender.full_name)
    @body[:content] = private_message.body
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
	if user_sender.superuser || user_sender.space_id == nil       
		if user_sender.main_space!= nil
	       	@body[:space_logo] = user_sender.main_space
	       else
			@body[:space_logo] = nil
	       end
       else
		@body[:space_logo] = Space.find(user_sender.space_id)
       end
    @body[:url] = "http://#{Site.current.domain}/" 
    @headers.store("Reply-To",user_sender.email)
  end
  
  private

  def setup_email(recipients)
    @recipients = recipients
    @from = "#{ Site.current.name } <#{ Site.current.email }>"
    @subject = I18n.t("vcc_mail_label") + " "
    @sent_on = Time.now
    @content_type ="text/html"
  end

  def reservation_request_notification_email(reservation, receiver)
    setup_email(receiver.email)

    user_sender = User.find(reservation.user_id)
    room = reservation.room
    @subject += I18n.t("reservation.notification.subject", :eventname=>reservation.title, :space=>room.space.name, :username=>user_sender.full_name, :room => room.name)
    @body[:reservation] = reservation
    @body[:room] = room
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil
    @body[:url] = "http://#{Site.current.domain}/" 
    @headers.store("Reply-To",user_sender.email)
  end

  def reservation_virtual_request_notification_email(reservation, receiver)
    setup_email(receiver.email)
  
    user_sender = User.find(reservation.user_id)
    room = reservation.room
    @subject += I18n.t("reservation.notification.virtual.subject", :eventname=>reservation.title, :space=>room.space.name, :username=>user_sender.full_name, :room => room.name)
    @body[:reservation] = reservation
    @body[:room] = room
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil
    @body[:url] = "http://#{Site.current.domain}/" 
    @headers.store("Reply-To",user_sender.email)
  end

  def reservation_processed_notification_email(reservation, receiver)
    setup_email(receiver.email)

    user_sender = User.find(reservation.admin_id)
    room = reservation.room
    @subject += I18n.t("reservation.notification.processed.subject", :eventname=>reservation.title, :space=>room.space.name, :username=>user_sender.full_name, :room => room.name, :action => reservation.state)
    @body[:reservation] = reservation
    @body[:room] = room
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil
    @body[:url] = "http://#{Site.current.domain}/" 
    @headers.store("Reply-To",user_sender.email)
  end

  def reservation_cancelled_notification_email(reservation, receiver)
    setup_email(receiver.email)

    user_sender = User.find(reservation.user_id)
    room = reservation.room
    @subject += I18n.t("reservation.notification.cancelled.subject", :eventname=>reservation.title, :space=>room.space.name, :username=>user_sender.full_name, :room => room.name, :action => reservation.state)
    @body[:reservation] = reservation
    @body[:room] = room
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil
    @body[:url] = "http://#{Site.current.domain}/" 
    @headers.store("Reply-To",user_sender.email)
  end

  def request_reservation_notification_email(request, receiver)
    setup_email(receiver.email)

    user_sender = User.find(request.sender_id)
    reservation = request.reservation
    @subject += I18n.t("reservation.notification.request.subject", :eventname=>reservation.title, 
      :username=>user_sender.full_name, :schedule => reservation.calendar_events.join(", "))
    @body[:reservation] = reservation
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil
    @body[:url] = "http://#{Site.current.domain}/" 
    @headers.store("Reply-To",user_sender.email)
  end
  
  def request_processed_notification_email(request, receiver)
    setup_email(receiver.email)

    user_sender = User.find(request.recipient_id)
    reservation = request.reservation
    @subject += I18n.t("reservation.notification.request.processed.subject", :eventname=>reservation.title, 
      :username => user_sender.full_name, :schedule => reservation.calendar_events.join(", "),
      :action => request.status)
    @body[:reservation] = reservation
    @body[:request] = request
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil
    @body[:url] = "http://#{Site.current.domain}/" 
    @headers.store("Reply-To",user_sender.email)
  end
  def room_update(room, receiver)
  	setup_email(receiver.email)
	
	@subject += I18n.t("room.notification.subject",  :room => room.name, :username => receiver.full_name)
	@body[:room] = room
       @body[:space] = room.space.name
	@body[:space_logo] = (room.space && room.space.parent) ? room.space : nil
	@body[:request] = room
	@body[:receiver] = receiver
	@body[:username] = receiver.full_name
	@body[:url] = "http://#{Site.current.domain}/manage/edit_room/#{room.id}"
  end
  def room_create(room, receiver)
  	setup_email(receiver.email)
	
	@subject += I18n.t("room.notification_create.subject",  :room => room.name, :username => receiver.full_name)
	@body[:room] = room
       @body[:space] = room.space.name
	@body[:space_logo] = (room.space && room.space.parent) ? room.space : nil
	@body[:request] = room
	@body[:receiver] = receiver
	@body[:username] = receiver.full_name
	@body[:url] = "http://#{Site.current.domain}/manage/edit_room/#{room.id}"
  end

  def reservation_cancelled_by_covi_notification_email(reservation, receiver)
    setup_email(receiver.email)

    user_sender = User.find(reservation.cancelled_by)
    room = reservation.room
    available_rooms = Room.available_rooms(receiver.spaces, reservation.calendar_events)
    @subject += I18n.t("reservation.notification.cancelled.subject", :eventname=>reservation.title, :space=>room.space.name, :username=>user_sender.full_name, :room => room.name, :action => reservation.state)
    @body[:reservation] = reservation
    @body[:room] = room
    @body[:reasons] = reservation.reason_rejection_text
    @body[:covi_notes] = reservation.notes
    @body[:available_rooms] = available_rooms.map{|r| r.name }.join(', ')
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender
    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil

    @body[:url] = "http://#{Site.current.domain}/reservation/new" 
    @headers.store("Reply-To",user_sender.email)
  end

  def reservation_cancelled_by_user_notification_email(reservation, receiver)
    setup_email(receiver.email)

    user_sender = User.find(reservation.cancelled_by)
    room = reservation.room
    @subject += I18n.t("reservation.notification.cancelled.subject", :eventname=>reservation.title, :space=>room.space.name, :username=>user_sender.full_name, :room => room.name, :action => reservation.state)
    @body[:reservation] = reservation
    @body[:room] = room
    @body[:reasons] = reservation.reason_rejection
    @body[:receiver] = receiver
    @body[:user_sender] = user_sender

    @body[:space_logo] = (reservation.space && reservation.space.parent) ? reservation.space : nil
    @body[:url] = "http://#{Site.current.domain}/reservation/new" 
    @headers.store("Reply-To",user_sender.email)
  end
  
  def reservation_invitation_notification(request, receiver)
  	setup_email(receiver.email)
	reservation= Reservation.find(request.reservation_id)
	room= Room.find(reservation.room_id) 
	username = User.find(request.recipient_id).full_name
	estado_aux=""
	if request.status == Request::STATUS_ACCEPTED
		estado_aux = "Aceptado"
	elsif  request.status == Reservation::ACTION_DECLINE_INVITATION
		estado_aux = "Rechazo"
	end
	
	@subject += I18n.t("room.invitation.subject",  :reservation => reservation.name, :username => receiver.full_name)
	@body[:room] = room
       @body[:space] = room.space.name
	@body[:space_logo] = room.space.name
	@body[:request] = request
	@body[:receiver] = receiver
	@body[:estado] = estado_aux
	@body[:username] = username
	@body[:url] = "http://#{Site.current.domain}/manage/edit_room/#{room.id}"
  end
end

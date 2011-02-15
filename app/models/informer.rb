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

#This class is the one in charge of informing users through the addecuate method
#private message or email in this version
class Informer
  
  
  def self.deliver_invitation(admission)
    if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.deliver_invitation_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.invitation_message(admission)        
     end
   end
   
   
   def self.deliver_event_invitation(admission)
     if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.deliver_event_invitation_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.event_invitation_message(admission)        
     end
   end
   
   def self.deliver_event_notification(event,receiver)
     if receiver.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.deliver_event_notification_email(event,receiver)
     elsif receiver.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.event_notification_message(event,receiver)
     end
   end
   
   def self.deliver_space_group_invitation(space,mail)
     Notifier.deliver_space_group_invitation_email(space,mail)
   end
   
   def self.deliver_event_group_invitation(event,mail)
     Notifier.deliver_event_group_invitation_email(event,mail)
   end      
   
   def self.deliver_join_request(admission) 
     #in this case the deliver is to the admins of the space so we have to decide
     #whether using a Private Message or an Email depending on their profile
     admission.group.users(:role => 'Admin').each do |admin|
       if admin.notification == User::NOTIFICATION_VIA_EMAIL
         Notifier.deliver_join_request_email(admission, admin)
       elsif admin.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.join_request_message(admission, admin)
       end
     end
   end
   
   
   def self.deliver_processed_invitation(admission)
     #in this case the deliver is to the admins of the space so we have to decide
     #whether using a Private Message or an Email depending on their profile
     admission.group.users(:role => 'Admin').each do |admin|
       if admin.notification == User::NOTIFICATION_VIA_EMAIL
         Notifier.deliver_processed_invitation_email(admission, admin)
       elsif admin.notification == User::NOTIFICATION_VIA_PM
         PrivateSender.processed_invitation_message(admission, admin)
       end
     end
   end
   
   
   def self.deliver_processed_join_request(admission)
     if !admission.candidate || admission.candidate.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.deliver_processed_join_request_email(admission)
     elsif admission.candidate.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.processed_join_request_message(admission)
     end
   end

   def self.deliver_reservation_request_notification(reservation, receiver)
     if receiver.notification == User::NOTIFICATION_VIA_EMAIL
       Notifier.deliver_reservation_request_notification_email(reservation,receiver)
     elsif receiver.notification == User::NOTIFICATION_VIA_PM
       PrivateSender.reservation_request_notification_message(reservation,receiver)
     end
   end

  def self.deliver_reservation_virtual_request_notification(reservation, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_reservation_virtual_request_notification_email(reservation,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.reservation_virtual_request_notification_message(reservation,receiver)
    end
  end

  def self.deliver_reservation_processed_notification(reservation, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_reservation_processed_notification_email(reservation,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.reservation_processed_notification_message(reservation,receiver)
    end
  end

  def self.deliver_reservation_cancelled_notification(reservation, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_reservation_cancelled_notification_email(reservation,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.reservation_cancelled_notification_message(reservation,receiver)
    end
  end

  def self.deliver_request_reservation_notification(request, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_request_reservation_notification_email(request,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.request_reservation_notification_message(request,receiver)
    end
  end
  
  def self.deliver_request_processed_notification(request, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_request_processed_notification_email(request,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.request_processed_notification_message(request,receiver)
    end
  end

  def self.deliver_room_update(request, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_room_update(request,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.room_update_message(request,receiver)
    end
  end
   
  def self.deliver_room_create(request, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_room_create(request,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.room_create_message(request,receiver)
    end
  end

  def self.deliver_reservation_cancelled_by_covi_notification(reservation, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_reservation_cancelled_by_covi_notification_email(reservation, receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.reservation_cancelled_by_covi_notification_message(reservation, receiver)
    end
  end

  def self.deliver_reservation_cancelled_by_user_notification(reservation, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_reservation_cancelled_by_user_notification_email(reservation, receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.reservation_cancelled_by_user_notification_message(reservation, receiver)
    end
  end
  def self.deliver_reservation_invitation_notification(request, receiver)
    if receiver.notification == User::NOTIFICATION_VIA_EMAIL
      Notifier.deliver_reservation_invitation_notification(request,receiver)
    elsif receiver.notification == User::NOTIFICATION_VIA_PM
      PrivateSender.reservation_invitation_notification(request,receiver)
    end
  end
end

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

class HomesController < ApplicationController
  
  before_filter :authentication_required

  def index
  end

  def update_spaces
     user_tmp= current_user
     rooms = Room.getManagedRooms(current_user)
     if params[:country_space] != nil && params[:country_space] != ""
     list_spaces=user_tmp.spaces.select {|s| s.country == params[:country_space] }
     else
     list_spaces=user_tmp.spaces
     end
     if rooms.count > 0
	render :partial => 'homes/user_spaces', :locals => {:show_user =>user_tmp, :title=>t('space.admin'),:list_user_spaces=>list_spaces}
     else
	render :partial => 'homes/user_spaces', :locals => {:show_user =>user_tmp, :title=>t('space.my_spaces'),:list_user_spaces=>list_spaces}
     end
  end 

  
  def show
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
      # quitar eventos privados
      @events_of_user.delete_if {|x| x.reservations != nil && 
                                  x.reservations.select {|y| y.type == 'private'}.size > 0 &&
                                    !(current_user.superuser || current_user.spaces.select {|z| z.role_for?(current_user, :name => 'Admin')}.size > 0 ||
                                    x.organizers.include?(current_user) || x.participants.map(&:user).include?(current_user)) }
    end

#    @contents_per_page = params[:per_page] || 30
    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents     
    @type = params[:type] || 'all'

    mensaje = ""

    @all_contents = Array.new

    clara_space = Space.root

    if params[:country] == nil
      case @type
        when 'old'
          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :conditions => ['created_at < current_date'], :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
        when 'clara'
          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => clara_space, :contents => @contents} )
        when 'events' 
          if !current_user.spaces.empty? && !current_user.superuser?
            @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => Space.find(:all, :conditions => ["id not in (?)", current_user.spaces]), :contents => @contents} )
          else
            @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'created_at DESC' },{ :containers => Space.all, :contents => @contents} )
          end
          @type= "events"
        when 'all'
          pending_reservations = Reservation.pending(current_user)
		
          if (pending_reservations.count > 0)
            @all_contents += pending_reservations
          end

          my_reservations = Reservation.owner_or_invited(current_user)

          if my_reservations.count > 0
            @all_contents += my_reservations
          end

          request_reservations = Request.pending(current_user)

          if (request_reservations.count > 0)
            @all_contents += request_reservations
          end

          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :conditions => ['created_at > current_date'], :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
        else
          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
      end
    else
      if params[:country] == ""
        if !current_user.spaces.empty? && !current_user.superuser?
          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => Space.find(:all, :conditions => ["id not in (?)", current_user.spaces]), :contents => @contents} )
        else
          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => Space.find(:all), :contents => @contents} )
        end
      else
        if !current_user.spaces.empty? && !current_user.superuser?
          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => Space.find(:all, :conditions => ["country = ? AND id not in (?)", params[:country], current_user.spaces] ), :contents => @contents} )
        else
          @all_contents += ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => Space.find(:all, :conditions => ["country = ?", params[:country]] ), :contents => @contents} )
        end
      end

      @type= "events"
      @country = params[:country]
      
#      aux = Space.find(:all, :conditions => ["country = ? AND id not in (?)", params[:country], current_user.spaces])
    end	
    @all_contents.uniq!
    @all_contents = @all_contents.sort {|a, b| b.updated_at <=> a.updated_at}
    # quitar eventos privados
    if !@all_contents.nil?
      @all_contents.delete_if {|x| x.class.to_s == 'Event' && x.reservations.size > 0 && 
                                   x.reservations.select {|y| y.reservation_type == 'private'}.size > 0 &&
                                     !(current_user.superuser || current_user.spaces.select {|z| z.role_for?(current_user, :name => 'Admin')}.size > 0 ||
                                     x.organizers.include?(current_user) || x.participants.map(&:user).include?(current_user)) }
    end

@all_contents = WillPaginate::Collection.create(params[:page] ? params[:page] : 1, @contents_per_page.to_i) do |pager|
  events = ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
    pager.replace @all_contents

    unless pager.total_entries
      # the pager didn't manage to guess the total count, do it manually
      pager.total_entries = @all_contents.size
    end
end


    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)

    @main_space = current_user.stages(:type => "Space").first
    @space = current_user.stages(:type => "Space").first

    # Solicitudes pendientes de procesar por el COVI
    if !current_user.spaces.empty?
      for space in current_user.spaces
        if space.role_for?(current_user, :name => 'Admin') && space.join_requests.pending.count > 0
           if mensaje.length == 0
             mensaje = "Tiene solicitudes de admision pendientes en <a href=\"#{space_admissions_path(space)}\">#{space.name}</a>"
           else
             mensaje += ", <a href=\"#{space_admissions_path(space)}\">#{space.name}</a>"
           end
        end
      end
    end

    # Solicitudes pendientes enviadas por usuario
    if Space.all_pending_join_requests_for(current_user)
      mensaje = mensaje.length > 0 ? mensaje + "<br />" + t('space.join_pendings') : t('space.join_pendings') 
    end

    if params[:country].present? && @all_contents.count == 0
      mensaje = mensaje.length > 0 ? mensaje + "<br />" + "No existen eventos en este pais." : "No existen eventos en este pais."
    end

    if mensaje.length > 0
      flash.now['notice'] = mensaje
    end
  end
end

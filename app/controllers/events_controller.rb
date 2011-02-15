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

require 'vpim/icalendar'
require 'vpim/vevent'
require 'vpim/duration'

class EventsController < ApplicationController
  # Include basic Resource methods
  # See documentation: ActionController::StationResources
  include ActionController::StationResources
  include SpamControllerModule 

  before_filter :space!
  before_filter :event, :only => [ :show, :edit, :update, :destroy ]

  before_filter :adapt_new_date, :only => [:create, :update]
  
  authorization_filter :create, :event, :only => [ :new, :create ]
  authorization_filter :read,   :event, :only => [ :show, :index ]
  authorization_filter :update, :event, :only => [ :edit, :update, :start ]
  authorization_filter :delete, :event, :only => [ :destroy ]

  # GET /events
  # GET /events.xml
  def index
    events
    
    respond_to do |format|
      format.html {
        if logged_in? && current_user.timezone == nil
          flash[:notice] = t('timezone.set_up', :path => edit_user_path(current_user))
        end
        if request.xhr?
          render :layout => false;
        end
      }
      format.xml  { render :xml => @events }
      format.atom
    end

  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @assistants =  @event.participants.select{|p| p.attend == true}
    @no_assistants = @event.participants.select{|p| p.attend != true} 
    @not_responding_candidates = @event.invitations.select{|e| !e.candidate.nil? && !e.processed?}
    @not_responding_emails = @event.invitations.select{|e| e.candidate.nil? && !e.processed?}
    @agenda_entry = AgendaEntry.new
    
    #For event repository
    @attachments,@tags = Attachment.repository_attachments(@event, params)
            
    #first check if it is an online event
	if @event.marte_event && params[:show_conference]
		#let's calculate the wait time
     @wait = (@event.start_date - Time.now).floor
     respond_to do |format|
       format.html {render :partial=> "online_event", :layout => "conference_layout"} # show.html.erb
       format.xml  { render :xml => @event }
       format.js 
       format.ics {name = "agenda_" + @event.name + ".ics"
         send_data @event.to_ics, :filename => "#{name}"}
       format.pdf { 
         name = "agenda_" + @event.name + ".pdf"
         send_data @event.to_pdf, :filename => "#{name}"
       }
     end
	else
  
    @comments = @event.posts.paginate(:page => params[:page],:per_page => 5)

    if params[:edit_event]
      @event_to_edit = Event.find_by_permalink(params[:edit_event])
      @invited_candidates = @event_to_edit.invitations.select{|e| !e.candidate.nil?}
      @invited_emails = @event_to_edit.invitations.select{|e| e.candidate.nil?}
      #array of users of the space minus the users that has already been invited
      @users_in_space_not_invited = @space.users - @invited_candidates.map(&:candidate)
    end

    # Clear bad params 
    params[:show_video]=nil if event.future?
   
    if !params[:show_agenda] && !params[:show_video] && !params[:show_repository] && !params[:show_streaming] && !params[:show_participation]
      #we decide the view depending on the date of the event, agenda for future events, streaming for happening now events
      # and recordings for past events
      if event.past? && event.agenda.has_entries_with_video?
        params[:show_video]=@event.agenda.first_video_entry_id.to_s
      elsif event.future? || (event.past? && !event.agenda.has_entries_with_video?)
        params[:show_agenda]=true
      elsif event.is_happening_now?
        params[:show_streaming]=true
      elsif !event.has_date?
        params[:show_agenda]=true
      end
    end
    
     if params[:show_video]
      if @event.agenda.present?
        @video_entries = @event.agenda.agenda_entries.select{|ae| ae.past? & ae.recording?}
      else
        @video_entries = []
      end
      #this is because googlebot asks for Arrays of videos and params[:show_video].to_i failed
      if params[:show_video].class == String
        @display_entry = AgendaEntry.find(params[:show_video].to_i)
      else
        @display_entry = nil
      end
#      #@show_day=0
#      for day in 1..@event.days
#        if @video_entries[day][params[:show_video].to_i]
#          #@show_day = day
#          @display_entry = @video_entries[day][params[:show_video].to_i]
#          break
#        end
#      end
    end

    respond_to do |format|
       format.html # show.html.erb
           format.xml  {render :xml => @event }
           format.ics {
              name = "agenda_" + @event.name + ".ics"
              send_data @event.to_ics, :filename => "#{name}"
           }
           format.pdf {
           
              @event.to_pdf
              nombre = "agenda_" + @event.permalink + ".pdf"
              pdf_path = "#{RAILS_ROOT}/public/pdf/#{@event.permalink}/#{nombre}"
              send_file pdf_path
              
#              nombre = "agenda_" + @event.name + ".pdf"
#              send_data @event.to_pdf, :filename => "#{nombre}"
           }  
    end
	end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit    
    @invited_candidates = @event.invitations.select{|e| !e.candidate.nil?}
    @invited_emails = @event.invitations.select{|e| e.candidate.nil?}
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.author = current_agent
    @event.container = space


    respond_to do |format|
      if @event.save
        #@event.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al evento
        format.html {
          flash[:success] = t('event.created')
          redirect_to space_event_path(space, @event)
        }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html {  
        message = ""
        @event.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        events
        render :action => "index"
        }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])        
		    #if the event is not marte, we have to remove the room in case it had it already assigned
		    if params[:event][:marte_event]==0 &&  @event.marte_room?
			    @event.update_attribute(:marte_room, false)
		    end
        @event.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al evento
        flash[:success] = t('event.updated')
        format.html {redirect_to space_event_path(@space, @event) }
        format.xml  { head :ok }
        format.js{
          if params[:event][:other_streaming_url]
            @result = params[:event][:other_streaming_url]
          end
          if params[:event][:other_participation_url]
            @result = params[:event][:other_participation_url]
          end
          if params[:event][:description]
            @result = params[:event][:description]
            @description=true
          end
        }
      else
        format.html { message = ""
        @event.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        redirect_to request.referer }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    reservation = Reservation.find(:first, :conditions => ["event_id = ? and state <> ?", @event.id, Reservation::STATE_DELETED])
    if reservation && reservation.state != Reservation::STATE_DELETED
      reservation.state = Reservation::STATE_DELETED
      reservation.cancelled_by = current_user.id
      reservation.event_id = nil
      reservation.delete_cascade
      reservation.save
    
      reservations = Reservation.find_by_parent_id(reservation.id)
      if reservations
        for c_reservation in reservations
          c_reservation.state = Reservation::STATE_DELETED
          c_reservation.delete_cascade
          c_reservation.save
        end
      end
    end
    respond_to do |format|
      if @event.destroy
        flash[:success] = t('event.deleted')
        if reservation
          format.html { redirect_to root_path }
        else
          format.html { redirect_to(space_events_path(@space)) }
        end
        format.xml  { head :ok }
      else
        format.html { message = ""
        @event.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        redirect_to request.referer }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end  
  end
  
  
  #method to get the token to participate in a online videoconference
  def token
	  #if the user is not logged in the name should be guest+number
	  if !logged_in?
		  @token = MarteToken.create :username=>"Guest-"+rand(100).to_s, :role=>"admin", :room_id=>params[:id]
	  else
		   @token = MarteToken.create :username=>current_user.name, :role=>"admin", :room_id=>params[:id]
	  end
	  
	  if @token.nil?
		  MarteRoom.create :name => params[:id]
		  if !logged_in?
			   @token = MarteToken.create :username=>"Guest-"+rand(100).to_s, :role=>"admin", :room_id=>params[:id]
	  	  else
		      @token = MarteToken.create :username=>current_user.name, :role=>"admin", :room_id=>params[:id]
	      end
	  end
	  if @token.nil?
		render :text => t('token.not_available'), :status => 500
	  else
	       render :text => @token.id
  	  end
  end

  def start
    event.start!
    event.errors.any? ?
      flash[:error] = event.errors.to_xml :
      flash[:success] = t('event.started')

    redirect_to event
  end
  
  private
  
  #method to adapt the start_date + number of days to the start_date and end_date that the event expects
  def adapt_new_date
    if params[:ndays]
      params[ :event][:end_date] = (Date.parse(params[:event][:start_date]) + params[:ndays].to_i).strftime("%d %b %Y")
    end
    
  end
  
  def future_and_past_events
    @future_events = @events.select{|e| e.start_date.future?}
    @past_events = @events.select{|e| e.start_date.past?}.sort!{|x,y| y.start_date <=> x.start_date} #Los eventos pasados van en otro inversos
  end
  
  
  def export_ical
      calen = Vpim::Icalendar.create2
      calen.add_event do |e|
        e.dtstart @event.start_date
        e.dtend   @event.end_date
        e.description @event.description
        e.summary   @event.name
        e.set_text('LOCATION', @event.place)
      end
      icsfile = calen.encode         
      send_data icsfile, :filename => "#{@event.name}.ics"      
      
  end

  def events
      @events = (Event.in(@space).all :order => "start_date ASC")

      # quitar eventos privados
      @events.delete_if {|x| x.reservations != nil && 
                             x.reservations.map {|y| y.reservation_type == 'private'}.size > 0 &&
                               !(current_user.superuser || @space.role_for?(current_user, :name => 'Admin') ||
                               x.organizers.include?(current_user) || x.participants.map(&:user).include?(current_user)) }
    
      #Current events
      @current_events = @events.select{|e| e.is_happening_now?}
    
      #events without date
      @undated_events = @events.select{|e| !e.has_date?}
    
      #Upcoming events
      @today_events = @events.select{|e| e.has_date? && e.start_date.to_date == Date.today && e.start_date.future?}
      @today_paginate_events = @today_events.paginate(:page => params[:page], :per_page => 5)
      @next_week_events = @events.select{|e| e.has_date? && e.start_date.to_date >= (Date.today) && e.start_date.to_date <= (Date.today + 7) && e.start_date.future?}
      @next_week_paginate_events= @next_week_events.paginate(:page => params[:page], :per_page => 5)
      @next_month_events = @events.select{|e| e.has_date? && e.start_date.to_date >= (Date.today) && e.start_date.to_date <= (Date.today + 30) && e.start_date.future?}
      @next_month_paginate_events = @next_month_events.paginate(:page => params[:page], :per_page => 5)
      @all_upcoming_events = @events.select{|e| e.has_date? && e.start_date.future?}
      @all_upcoming_paginate_events = @all_upcoming_events.paginate(:page => params[:page], :per_page => 5)
      @undated_paginated_events = @undated_events.paginate(:page => params[:page], :per_page => 5)
=begin      
      if params[:day] == "today"
        @upcoming_title = "Today Events"
      elsif params[:day] == "next_week"
        @upcoming_title = "Next Week Events"
      elsif params[:day] == "next_month"
        @upcoming_title = "Next Month Events"
      else
        @upcoming_title = "All upcoming Events"
      end
=end
      #Past events
      @today_and_yesterday_events = @events.select{|e| e.has_date? && ( e.end_date.to_date==Date.today || e.end_date.to_date==Date.yesterday) && !e.end_date.future?}      
      @last_week_events = @events.select{|e| e.has_date? && e.start_date.to_date <= (Date.today) && e.end_date.to_date >= (Date.today - 7) && !e.end_date.future?}
      @last_month_events = @events.select{|e| e.has_date? && e.start_date.to_date <= (Date.today) && e.end_date.to_date >= (Date.today - 30) && !e.end_date.future?}
      @all_past_events = @events.select{|e| e.has_date? && !e.end_date.future?}
      
      if params[:order_by_time] != "ASC"
       @today_and_yesterday_events.reverse! 
       @last_week_events.reverse!
       @last_month_events.reverse!
       @all_past_events.reverse! 

      end
      @today_and_yesterday_paginate_events = @today_and_yesterday_events.paginate(:page => params[:page], :per_page => 5)
      @last_week_paginate_events = @last_week_events.paginate(:page => params[:page], :per_page => 5)
      @last_month_paginate_events = @last_month_events.paginate(:page => params[:page], :per_page => 5)      
      @all_past_paginate_events = @all_past_events.paginate(:page => params[:page], :per_page => 5)

=begin
      if params[:day] == "yesterday"
        @past_events_events = @today_and_yesterday_events 
        @past_title = "Today Past Events and Yesterday Events"
      elsif params[:day] == "last_week"
        @past_events = @next_week_events
        @past_title = "Last Week Events"
      elsif params[:day] == "last_month"
        @past_events = @next_month_events
        @past_title = "Last Month Events"
      else
        @past_events = @all_past_events
        @past_title = "All Past Events"
      end           
      
      @past_events = @events.select{|e| !e.start_date.future?}.reverse.paginate(:page => params[:page], :per_page => 10)
=end
      #First 5 past and upcoming events
      
      @last_past_events = @all_past_events.first(2)     
      @first_upcoming_events = @all_upcoming_events.first(2)
      @first_undated_events = @undated_events.first(2)
      
      if params[:edit]
        @event_to_edit = Event.find_by_permalink(params[:edit])
        @invited_candidates = @event_to_edit.invitations.select{|e| !e.candidate.nil?}
        @invited_emails = @event_to_edit.invitations.select{|e| e.candidate.nil?}
        #array of users of the space minus the users that has already been invited
        @users_in_space_not_invited = @space.users - @invited_candidates.map(&:candidate)
      end
    end
end



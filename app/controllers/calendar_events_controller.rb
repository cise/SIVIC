class CalendarEventsController < ApplicationController
   
    def new
      starttime = params[:start]
      endtime = params[:end]
      allDay = params[:allDay]
      @room = Room.find(params[:room_id])
      logger.error "starttime => #{starttime}, endtime => #{endtime}, all_day => #{allDay}"
      @event = CalendarEvent.new(:starttime => starttime ? starttime[0,20].strip : "", :endtime => endtime ? endtime[0,20].strip : "", :all_day => allDay, :period => "Does not repeat")
    end
    
    def create
      if params[:calendar_event][:period] == "Does not repeat"
        @event = CalendarEvent.new(params[:calendar_event])
      else
        #@event_series = EventSeries.new(:frequency => params[:event][:frequency], :period => params[:event][:repeats], :starttime => params[:event][:starttime], :endtime => params[:event][:endtime], :all_day => params[:event][:all_day])
        @event_series = CalendarEventSeries.new(params[:calendar_event])
        if (params[:repeat_until][:year] != "" && params[:repeat_until][:month] != "" && params[:repeat_until][:day] != "")
          @event_series.repeat_until = Date.civil(params[:repeat_until][:year].to_i, params[:repeat_until][:month].to_i, params[:repeat_until][:day].to_i)
          @event_series.save
        end
      end
    end
    
    def index
      if !params[:reservation] || params[:reservation][:title] == ''
        render :text => 'Debe poner titulo a la reserva'
        return
      end

      if !params[:reservation] || params[:reservation][:room_id] == ''
        render :text => 'Debe seleccionar una sala'
        return
      end
      @room = Room.find(params[:reservation][:room_id])
      if params[:room_ids] && params[:room_ids] != "Selecciones otras salas" 
        @rooms = Room.find(params[:room_ids].split(","))
      end
      # @vc_service = params[:reservation][:vc_service]
    end

    def available
      @room = Room.find(params[:room_id])
    end
    
    def schedule
      @room = Room.find(params[:id])
    end

    def get_schedule_events
      @room = Room.find(params[:room_id])
      CalendarEventSeries.find_or_create Time.at(params['start'].to_i),Time.at(params['end'].to_i),@room.id

      events = []
      # Not available schedule
      @events = @room.calendar_events.select {|x| x.starttime >= Time.at(params['start'].to_i) && x.endtime <= Time.at(params['end'].to_i)}

      @events.each do |event|
        events << {:id => event.id, :title => event.title, 
                   :description => event.description || "Some cool description here...", 
                   :start => event.starttime.in_time_zone(Time.zone).to_s[0,20].strip, 
                   :end => event.endtime.in_time_zone(Time.zone).to_s[0,20].strip, 
                   :allDay => event.all_day, 
                   :recurring => (event.calendar_event_series_id)? true: false,
                   :editable => true, 
                   :className => "not-available"}
#        if event.calendar_event_series_id?
#        end
      end
      render :text => events.to_json
    end

    def get_calendar_events
      events = []
      # Current reservations
      if params[:calendar_events] != nil
        calendar_events_ids = params[:calendar_events].strip().split(' ')
        @calendar_events = CalendarEvent.find(calendar_events_ids)
        @calendar_events.each do |event|
        events << {:id => event.id, :title => event.title, 
                   :description => event.description || "Some cool description here...", 
                   :start => event.starttime.in_time_zone(Time.zone).to_s[0,20].strip, 
                   :end => event.endtime.in_time_zone(Time.zone).to_s[0,20].strip, 
                     :allDay => event.all_day, 
                     :editable => true,
                     :recurring => (event.calendar_event_series_id)? true: false}
        end
      end

      render :text => events.to_json
    end

    def get_room_reservations_events
      @room = Room.find(params[:room_id])

      events = []
      # reservations
      @reservations = @room.reservations.select {|r| r.state == Reservation::STATE_APPROVED }
      
      @reservations.each do |reservation|
        @events = reservation.calendar_events.select {|x| x.starttime >= Time.at(params['start'].to_i) && x.endtime <= Time.at(params['end'].to_i)}
        @events.each do |event|
          events << {:id => event.id, :title => event.title, 
                     :description => event.description || "Some cool description here...", 
                     :start => event.starttime.in_time_zone(Time.zone).to_s[0,20].strip, 
                     :end => event.endtime.in_time_zone(Time.zone).to_s[0,20].strip,
                     :allDay => event.all_day,
                     :editable => false, 
                     :recurring => (event.calendar_event_series_id)? true: false,
                     :className => "reserved" }
        end
      end
       
      render :text => events.to_json
    end

    def get_room_events
      @room = Room.find(params[:room_id])

      CalendarEventSeries.find_or_create Time.at(params['start'].to_i),Time.at(params['end'].to_i),@room.id
       
      events = []
      # Not available schedule
      @events = @room.calendar_events.select {|x| x.starttime >= Time.at(params['start'].to_i) && x.endtime <= Time.at(params['end'].to_i)}
      @events.each do |event|
        events << {:id => event.id, :title => event.title, 
                   :description => event.description || "Some cool description here...", 
                   :start => event.starttime.in_time_zone(Time.zone).to_s[0,20].strip, 
                   :end => event.endtime.in_time_zone(Time.zone).to_s[0,20].strip,
                   :allDay => event.all_day, 
                   :recurring => (event.calendar_event_series_id)? true: false,
                   :editable => false, 
                   :className => "not-available"}
      end
      
      # Others reservations
      @reservations = @room.reservations.select {|r| r.state == Reservation::STATE_APPROVED }
      
      @reservations.each do |reservation|
        @events = reservation.calendar_events.select {|x| x.starttime >= Time.at(params['start'].to_i) && x.endtime <= Time.at(params['end'].to_i)}
        @events.each do |event|
          events << {:id => event.id, :title => event.title, 
                     :description => event.description || "Some cool description here...", 
                     :start => event.starttime.in_time_zone(Time.zone).to_s[0,20].strip, 
                     :end => event.endtime.in_time_zone(Time.zone).to_s[0,20].strip,
                     :allDay => event.all_day,
                     :editable => false, 
                     :recurring => (event.calendar_event_series_id)? true: false,
                     :className => "reserved" }
        end
      end
       
      render :text => events.to_json
    end

    def get_others_events
      rooms = Room.find(params[:room_ids].split(","))
      events = []
      rooms.each do |room|
        calendar_events = room.calendar_events.select {|x| x.starttime >= Time.at(params['start'].to_i) && x.endtime <= Time.at(params['end'].to_i)}
        calendar_events.each do |calendar_event|
          events << {:id => calendar_event.id, :title => room.name + ": " + calendar_event.title,
                     :description => calendar_event.description,
                     :start => calendar_event.starttime.in_time_zone(Time.zone).to_s[0,20].strip, 
                     :end => calendar_event.endtime.in_time_zone(Time.zone).to_s[0,20].strip, 
                     :allDay => calendar_event.all_day,
                     :editable => false,
                     :recurring => (calendar_event.calendar_event_series_id)? true: false,
                     :className => "not-available"
          }
        end        
        reservations = room.reservations
        reservations.each do |reservation|
          reservations_events = reservation.calendar_events.select {|x| x.starttime >= Time.at(params['start'].to_i) && x.endtime <= Time.at(params['end'].to_i)}
          reservations_events.each do |reservation_event|
            events << {:id => reservation_event.id, :title => room.name + ": " + reservation_event.title,
                       :description => reservation_event.description,
                       :start => reservation_event.starttime.in_time_zone(Time.zone).to_s[0,20].strip, 
                       :end => reservation_event.endtime.in_time_zone(Time.zone).to_s[0,20].strip, 
                       :allDay => reservation_event.all_day,
                       :editable => false,
                       :recurring => (reservation_event.calendar_event_series_id)? true: false,
                       :className => "reserved2"
            }
          end          
        end        
      end
      render :text => events.to_json
    end
    
    def get_events
      @events = CalendarEvent.find(:all, :conditions => ["starttime >= '#{Time.at(params['start'].to_i).to_formatted_s(:db)}' and endtime <= '#{Time.at(params['end'].to_i).to_formatted_s(:db)}'"] )
      events = [] 
      @events.each do |event|
        events << {:id => event.id, :title => event.title, :description => event.description || "Some cool description here...", :start => "#{event.starttime.iso8601}", :end => "#{event.endtime.iso8601}", :allDay => event.all_day, :recurring => (event.calendar_event_series_id)? true: false}
      end
      render :text => events.to_json
    end
    
    
    
    def move
      @event = CalendarEvent.find_by_id params[:id]
      if @event
        @event.starttime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@event.starttime))
        @event.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@event.endtime))
        @event.all_day = params[:all_day]
        @event.save
      end
    end
    
    
    def resize
      @event = CalendarEvent.find_by_id params[:id]
      if @event
        @event.endtime = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@event.endtime))
        @event.save
      end    
    end
    
    def edit
      @event = CalendarEvent.find_by_id(params[:id])
    end
    
    def update
      @event = CalendarEvent.find_by_id(params[:calendar_event][:id])
      if params[:calendar_event][:commit_button] == "Actualizar todas las instancias"
        @events = @event.calendar_event_series.calendar_events #.find(:all, :conditions => ["starttime > '#{@event.starttime.to_formatted_s(:db)}' "])
        @event.update_calendar_events(@events, params[:calendar_event])
      elsif params[:calendar_event][:commit_button] == "Actualizar todas las instancias siguientes"
        @events = @event.calendar_event_series.calendar_events.find(:all, :conditions => ["starttime > '#{@event.starttime.to_formatted_s(:db)}' "])
        @event.update_calendar_events(@events, params[:calendar_event])
      else
        @event.attributes = params[:calendar_event]
        if params[:calendar_event][:period] != "Does not repeat"
          @event_series = CalendarEventSeries.new(params[:calendar_event])
          @event_series.repeat_until = Date.civil(params[:repeat_until][:year].to_i, params[:repeat_until][:month].to_i, params[:repeat_until][:day].to_i)
          @event_series.object_type = @event.object_type
          @event_series.object_id = @event.object_id
          @event_series.save

          @event.calendar_event_series = @event_series
        end
        @event.save
      end
  
      render :update do |page|
        page<<"$('#calendar').fullCalendar( 'refetchEvents' )"
        page<<"$('#desc_dialog').dialog('destroy')" 
      end
      
    end  
    
    def destroy
      @event = CalendarEvent.find_by_id(params[:id])
      if params[:delete_all] == 'true'
        @event.calendar_event_series.destroy
      elsif params[:delete_all] == 'future'
        @events = @event.calendar_event_series.calendar_events.find(:all, :conditions => ["starttime > '#{@event.starttime.to_formatted_s(:db)}' "])
        @event.calendar_event_series.calendar_events.delete(@events)
      else
        @event.destroy
      end
      
      render :update do |page|
        page<<"if (parent.$('#reservation_calendar_events').val()) { parent.$('#reservation_calendar_events').val(parent.$('#reservation_calendar_events').val().replace('#{@event.id}','')) };"
        page<<"$('#calendar').fullCalendar( 'refetchEvents' )"
        page<<"$('#desc_dialog').dialog('destroy')" 
      end
      
    end

 def show
      calendar_events_ids = params[:calendar_events].strip().split(' ')
      calendar_events = CalendarEvent.find(calendar_events_ids)
      @schedules = ""

      calendar_events.sort {|a,b| a.starttime <=> b.starttime}.each do |calendar_event|
        @schedules += "<li id='calendar_schedule_#{calendar_event.id}' class='bit-box' rel='#{calendar_event.id}'>" +
          "#{calendar_event}"+
          "<a class='closebutton' href='#' "+
          "onclick='$.ajax({url: \\\"/calendar_events/delete?id=#{calendar_event.id}\\\"});'>" +
          "</a></li>"
      end 
      render :update do |page|
        page << "$('#holder_schedules').html(\""+@schedules+"\");"
      end
    end
    
  def delete
    calendar_event = CalendarEvent.find_by_id(params[:id])
    calendar_event.destroy
  
    render :update do |page|
      page << "if ($('#reservation_calendar_events').val()) { $('#reservation_calendar_events').val($('#reservation_calendar_events').val().replace('#{calendar_event.id}','')); }"
      page << "$.ajax({url: '/calendar_events/show?calendar_events='+$('#reservation_calendar_events').val()})" 
    end  
  end
end

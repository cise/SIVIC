class ReservationsController < ApplicationController
  before_filter :authentication_required
  # GET /reservations
  # GET /reservations.xml
  def index
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless current_user.spaces.empty?
         @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
       end
          @contents_per_page = params[:per_page] || 15
          @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
          @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
      
          #let's get the inbox for the user
          @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
    
    @reservations = Reservation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reservations }
    end
  end
  
  # GET /reservations/1
  # GET /reservations/1.xml
  def show
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reservation }
    end
  end

  # GET /reservations/new
  # GET /reservations/new.xml
  def new
    @main_space = current_user.main_space
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
    end
       @contents_per_page = params[:per_page] || 15
       @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
       @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
   
       #let's get the inbox for the user
       @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
    
    @countries = Room.getCountriesBySpaces(current_user.spaces)
    #@countries = Room.getCountries()
    
    @rooms = nil
    if params[:reservation] != nil 
      @rooms = Room.getRoomsByCountry(params[:reservation][:country])
    end
      
    @reservation = Reservation.new
    @reservation.requests.build

    respond_to do |format|
      if authenticated? && ! current_agent.active?
        format.html { redirect_back_or_default root_path }
      else
        if logged_in? && current_user.timezone == nil
          flash[:notice] = t('timezone.set_up', :path => edit_user_path(current_user))
        end
        format.html # new.html.erb
        format.xml  { render :xml => @reservation }
      end
    end
  end

  # GET /reservations/1/edit
  def edit
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @reservation = Reservation.find(params[:id])
  end

  # POST /reservations
  # POST /reservations.xml
  def create
    covi=false
	
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless  current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date")
    end
    
    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)

    @reservation = Reservation.new(params[:reservation])

    @reservation.state = Reservation::STATE_PENDING
    @reservation.user_id = current_user.id
    
    if params[:calendar_events] != nil
      calendar_events_ids = params[:calendar_events].strip().split(' ')
      calendar_events = CalendarEvent.find(calendar_events_ids)
      @reservation.calendar_events = calendar_events
    end

    if params[:participantes] != nil
      @checked_users = params[:participantes].strip().split(',')
    end

    respond_to do |format|
      if @reservation.calendar_events.size > 0
		@reservation.horario = 1
      end

      if @checked_users.size > 0
		@reservation.participante = 1
      end
	  
	  if @reservation.room_id!=nil
		  room1 = Room.find(@reservation.room_id)
		   room_users= room1.users_by_role("COVI")
		   
		   if room_users.size > 0
			for room_user in room_users 
				if room_user.id == current_user.id
					covi=true
					@reservation.state = Reservation::STATE_APPROVED
					@reservation.admin_id = current_user.id
				end	
			end		
		 end
	  end

      if (@reservation.save)
        for user_id in @checked_users 
          invitation = Request.new
          invitation.reservation_id = @reservation.id
          #invitation.message = @message
          invitation.sender_id = current_user.id
          invitation.recipient_id = user_id
          invitation.status = Request::STATUS_WAITING
          
          invitation.save
        end
		 
	   
		
		if covi
			create_event
		end
		
        flash[:notice] = 'La reservación fue creada exitosamente'
#        format.html { redirect_to(@reservation) }
        format.html { redirect_to root_path }
        format.xml  { render :xml => @reservation, :status => :created, :location => @reservation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reservation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reservations/1
  # PUT /reservations/1.xml
  def update
#    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @reservation = Reservation.find(params[:id])

    # Aprobar o rechazar la reserva
    if params[:submit] == Reservation::ACTION_APPROVE || params[:submit] == Reservation::ACTION_REJECT
      @reservation.admin_id = current_user.id     

      # Aprobar
      if params[:submit] == Reservation::ACTION_APPROVE
        @reservation.state = Reservation::STATE_APPROVED

        if !@reservation.parent_id?
          create_event 
        else
          event_id = Reservation.find(@reservation.parent_id).event_id
          participant = Participant.find(:first, :conditions => ["event_id = ? and user_id = ?", event_id, @reservation.user_id])
          if participant
            participant.attend = true
            participant.save
          end
        end

        @reservation.room.cancel_reservations(@reservation)
=begin
        # Crear evento
        event = Event.new(
          :name => @reservation.title, :description => @reservation.description,
          :web_interface => 1, :isabel_interface => 1, :sip_interface => 0, 
          :ids => @reservation.requests.collect {|x| x.recipient_id}, 
          :invite_msg => I18n.t(
            "reservation.notification.request.body", :eventname=>@reservation.title, 
            :username => @reservation.user.full_name, 
            :schedule => @reservation.calendar_events.map {|x| x.to_s }.join(", ")
          ) + ".\n\r" + I18n.t('reservation.notification.request.footer', :url => "http://#{Site.current.domain}/" )
        )

        event.container = @reservation.room.space
        event.author = @reservation.user
        event.invit_introducer_id = @reservation.user.id

        event.save
        
        @reservation.event_id = event.id
        # crear fechas de evento
        for calendar_event in @reservation.calendar_events
          agenda_entry = AgendaEntry.new(:title => @reservation.title, :description => @reservation.description,
            :start_time => calendar_event.starttime, :end_time => calendar_event.endtime)
          agenda_entry.agenda = event.agenda
          agenda_entry.author = @reservation.user

          logger.debug "instance agenda_entry = #{agenda_entry}"          
          if !agenda_entry.save
            message = ""
            agenda_entry.errors.full_messages.each {|msg| message += msg + "  <br/>"}
            logger.debug "error messages = #{message}"  
          end
        end

        # Actualizar estado de invitaciones
        for request in @reservation.requests
          request.status = Request::STATUS_PENDING
          request.save
        end
=end
      
      # Rechazar
      elsif params[:submit] == Reservation::ACTION_REJECT
        @reservation.state = Reservation::STATE_REJECTED
        @reservation.notes = params[:reservation][:notes]
        @reservation.reason_rejection = params[:reservation][:reason_rejection]

        if @reservation.parent_id?
          invitation = Request.new
          invitation.reservation_id = @reservation.parent_id
          #invitation.message = @message
          invitation.sender_id = @reservation.parent.user_id
          invitation.recipient_id = @reservation.user_id
          invitation.status = Request::STATUS_PENDING
          invitation.save
        end
      end

    # Aceptar o Declinar invitacion
    elsif params[:submit] == Reservation::ACTION_ACCEPT_INVITATION ||
          params[:submit] == Reservation::ACTION_DECLINE_INVITATION
      request = Request.find(params[:request_id])

      # Aceptar
      if params[:submit] == Reservation::ACTION_ACCEPT_INVITATION
        request.status = Request::STATUS_ACCEPTED
        logger.debug "new reservation country = #{params[:reservation][:country][@reservation.id]} room_id = #{params[:reservation][:room_id][@reservation.id]}"  
        new_reservation = Reservation.new
        new_reservation.title = @reservation.title
        new_reservation.description = @reservation.description
        new_reservation.vc_service = @reservation.vc_service
        new_reservation.space_id = @reservation.space_id
        new_reservation.country = params[:reservation][:country][@reservation.id.to_s]
        new_reservation.room_id = params[:reservation][:room_id][@reservation.id.to_s]
        new_reservation.aggrement = true
        new_reservation.state = Reservation::STATE_PENDING
        if new_reservation.room_id!=nil
          room1 = Room.find(new_reservation.room_id)
          room_users= room1.users_by_role("COVI")

          if room_users.size > 0
            for room_user in room_users 
              if room_user.id == current_user.id
                covi=true
                new_reservation.state = Reservation::STATE_APPROVED
                new_reservation.admin_id = current_user.id
              end        
            end                
          end
        end

        new_reservation.user_id = current_user.id
        new_reservation.parent_id = @reservation.id

        # Obtener fechas de calendario
        new_reservation.calendar_events = @reservation.calendar_events
#        if params[:calendar_events] != nil
#          calendar_events_ids = params[:calendar_events].strip().split(' ')
#          calendar_events = CalendarEvent.find(calendar_events_ids)
#          new_reservation.calendar_events = calendar_events 
#        end

      # Declinar
      elsif params[:submit] == Reservation::ACTION_DECLINE_INVITATION
        request.status = Request::STATUS_DECLINED
      end

      request.save
	  #ivan
	  @reservation.id_invitacion=request.id
    end
    
    respond_to do |format|
      if params[:submit] != Reservation::ACTION_ACCEPT_INVITATION && 
         params[:submit] != Reservation::ACTION_DECLINE_INVITATION
logger.error "notes=#{params[:reservation][:notes]}"
        if @reservation.update_attributes(params[:reservation])
          flash[:notice] = 'La reservación fue ' + @reservation.state + ' exitosamente.'
          # format.html { redirect_to(@reservation) }
          format.html { redirect_to root_path }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @reservation.errors, :status => :unprocessable_entity }
        end
      else
        if params[:submit] == Reservation::ACTION_ACCEPT_INVITATION
          if new_reservation.save
            flash[:notice] = 'La reservación fue creada exitosamente.'
            # format.html { redirect_to(new_reservation) }
            format.html { redirect_to root_path }
            format.xml  { head :ok }
          else
logger.error "#{new_reservation.errors.each{|attr,msg| "#{attr} - #{msg}. "}}"
            flash[:notice] = 'Ocurrio un error al enviar la reservacion. ' 
            format.html { redirect_to root_path }
#            format.html { render :text => new_reservation.errors }
            format.xml  { render :xml => @reservation.errors, :status => :unprocessable_entity }
          end
        else
          flash[:notice] = 'La invitación fue declinada exitosamente.'
          format.html { redirect_to root_path }
        end
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.xml
  def destroy
    @reservation = Reservation.find(params[:id])

    if @reservation.state == Reservation::STATE_APPROVED
      @reservation.reason_rejection = params[:reservation][:reason_rejection]
      @reservation.notes = params[:reservation][:notes]
      @reservation.cancelled_by = current_user.id
    end

    @reservation.state = Reservation::STATE_DELETED

    @reservation.delete_cascade
    @reservation.save

    childs = Reservation.find(:all, :conditions => ["parent_id = ?", @reservation.id])
    if !childs.nil?
      for reservation in childs
        reservation.state = Reservation::STATE_DELETED
        reservation.save

        reservation.delete_cascade
      end
    end

    if !@reservation.event_id.nil?
      event = Event.find(@reservation.event_id)
      if !event.nil?
        event.destroy
      end
     end

#    @reservation.destroy

    respond_to do |format|
      flash[:notice] = 'La reservación fue cancelada exitosamente.'
#      format.html { redirect_to(reservations_url) }
      format.html { redirect_to root_path }
      format.xml  { head :ok }
    end
  end
      
  def update_list_room
    # updates list rooms based on country selected
    @rooms = Room.find_all_by_country(params[:country])

    render :partial => 'list_rooms', :object => @rooms
  end

  def update_list_room_invitation
    # updates list rooms based on country selected
    @reservation = Reservation.find(params[:id])
    @rooms = Room.find_all_by_country(params[:country]).select {|r| r.id == @reservation.room_id || r.available(@reservation.calendar_events)}
# || (CalendarEvent.find_room(@reservation, r.id) && CalendarEvent.find_room_reserved(@reservation, r.id))}
    render :partial => 'list_rooms_invitation', :locals => {:reservation_id => @reservation.id}
  end

  def rechazada
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
    end

    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
  
    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)

    @reservations = Reservation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reservations }
    end
  end
      
  def aceptada
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
    end

    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)

    @reservations = Reservation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reservations }
    end
  end
      
  def autorizacion
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
    end

    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)

    @reservations = Reservation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reservations }
    end
  end
        
  def invitacion
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
    end

    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)

    @reservations = Reservation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reservations }
    end
  end 
  

  def pendiente
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @reservations = Reservation.all
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def pending
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
    end
    
    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
        
    @reservations = Reservation.pending(current_user)
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def add_user
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @reservation = Reservation.new(params[:reservation])
    @reservation.state = Reservation::STATE_PENDING
    @reservation.user_id = current_user.id
    @checked_users = params[:reservation_participantes].strip().split(',')
      
    #render :layout=>false;
    #render :partial => "add_user" if request.xhr?   
    respond_to do |format|
     format.html  { render :layout=>false;}
        format.xml  { render :xml => @reservations }
     end
  end
  def find_room
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    respond_to do |format|
         format.html # index.html.erb
         format.xml  { render :xml => @reservations }
       end
  end
  
  def information
    #render :layout=>false;
    #render :partial => "information" if request.xhr?   
    respond_to do |format|
     format.html  { render :layout=>false;}
        format.xml  { render :xml => @reservations }
     end
  end

  def information_service
    #render :layout=>false;
    #render :partial => "information" if request.xhr?   
    respond_to do |format|
     format.html  { render :layout=>false;}
        format.xml  { render :xml => @reservations }
     end
  end

  def port
    #render :layout=>false;
    #render :partial => "port" if request.xhr?   
    respond_to do |format|
     format.html  { render :layout=>false;}
        format.xml  { render :xml => @reservations }
     end
  end

  def participantes
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    if params[:invitation].present?
      if (params[:invitation][:recipient_ids].is_a?(Array))
        @checked_users = params[:invitation][:recipient_ids]
      else
        @checked_users = params[:invitation][:recipient_ids].strip().split(",")
      end
    end

    @name=""
    @id=""
      for user_id in @checked_users 
        @usuario= User.find(user_id)
        
        @name += "<li id='participants_#{@usuario.id}' class='bit-box' rel='#{@usuario.id}'>" +
          "#{@usuario.fullname_email_space}"+
          "<a class='closebutton' href='#' "+
          "onclick='$(\\\"#reservation_participantes\\\").val($(\\\"#reservation_participantes\\\").val().replace(\\\"#{@usuario.id},\\\",\\\"\\\"));"+
          "$.ajax({url: \\\"reservations/participantes\\\", data: \\\"invitation[recipient_ids]=\\\" + $(\\\"#reservation_participantes\\\").val()});'></a></li>"

        @id= @id + user_id + ","
      end 
   
    @name = @name + "<br />"
      render :update do |page|
           page << "$('#holder_participants').html(\""+ @name +"\")"
           page << "$('#reservation_participantes').val(\""+@id +"\")   " 
      end
      
      
   end

   def rejecting
     @reservation = Reservation.find(params[:reservation_id])
     render :layout => 'popup'
   end

   def cancel_by_covi
     @reservation = Reservation.find(params[:reservation_id])
     render :layout => 'popup'
   end

   def cancel_by_user
     @reservation = Reservation.find(params[:reservation_id])
     render :layout => 'popup'
   end

  private

  def create_event 
    # Crear evento
    event = Event.new(
      :name => @reservation.title, :description => @reservation.description,
      :web_interface => 1, :isabel_interface => 1, :sip_interface => 0, 
      :ids => @reservation.requests.collect {|x| x.recipient_id},
      :calendar_events => @reservation.calendar_events, 
      :invite_msg => I18n.t(
        "reservation.notification.request.body", :eventname=>@reservation.title, 
        :username => @reservation.user.full_name,
#        :schedule => @reservation.calendar_events.map {|x| x.to_s }.join(", ")
        :schedule => "{{schedule}}"
      ) + ".\n\r" + I18n.t('reservation.notification.request.footer', :url => "http://#{Site.current.domain}/" )
    )

#    event.container = @reservation.room.space
    event.container = @reservation.space ? @reservation.space : @reservation.room.space
    event.author = @reservation.user
    event.invit_introducer_id = @reservation.user.id
    
    event.save

    @reservation.event_id = event.id
    # agregar participantes
    for request in @reservation.requests
      invited = User.find(request.recipient_id)
      participant = Participant.new(:email => invited.email, :user_id => invited.id, :event_id => event.id)
      participant.save
    end

    # crear fechas de evento
    for calendar_event in @reservation.calendar_events
      agenda_entry = AgendaEntry.new(:title => @reservation.title, :description => @reservation.description,
        :start_time => calendar_event.starttime, :end_time => calendar_event.endtime
      )
      agenda_entry.agenda = event.agenda
      agenda_entry.author = @reservation.user

      if !agenda_entry.save
        message = ""
        agenda_entry.errors.full_messages.each {|msg| message += msg + "  <br/>"}
      end
    end

    # Actualizar estado de invitaciones
    for request in @reservation.requests
      request.status = Request::STATUS_PENDING
      request.save
    end
  end

end

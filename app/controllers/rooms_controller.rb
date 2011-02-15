class RoomsController < ApplicationController
  include ActionController::StationResources

  before_filter :space

  authentication_filter :only => [:new, :create]
#  authorization_filter :create, :room, :only => [:new, :create]
#  authorization_filter :read,   :room, :only => [:show]
#  authorization_filter :update, :room, :only => [:edit, :update]
#  authorization_filter :delete, :room, :only => [:destroy, :enable]

  # GET /rooms
  # GET /rooms.xml
  def index
    @rooms = space.rooms

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rooms }
    end
  end

  # GET /rooms/1
  # GET /rooms/1.xml
  def show
    @room = Room.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @room }
    end
  end

  # GET /rooms/new
  # GET /rooms/new.xml
  def new
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    unless current_user.spaces.empty?
     @events_of_user = Event.in(current_user.spaces).all(:order => "start_date DESC")
    end
      @contents_per_page = params[:per_page] || 15
      @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
      @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )
  
      #let's get the inbox for the user
      @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
    
    @room = Room.new
    @room.country = Country.find_by_code(space.country).name
    @room.space = space

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @room }
    end
  end

  # GET /rooms/1/edit
  def edit
    @main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @room = Room.find(params[:id])
	
	respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rooms }
    end
  end

  # POST /rooms
  # POST /rooms.xml
  def create
    @room = Room.new(params[:room])
    @room.service_type = Room::SERVICE_TYPE_NOT_CERTIFIED
    @room.certification_level = Room::SERVICE_TYPE_NOT_CERTIFIED
    @room.reevaluation=false

    respond_to do |format|
      if @room.save
        flash[:notice] = 'La sala fue creada exitosamente.'
        format.html { redirect_to("/spaces/#{@room.space.permalink}/rooms") }
        format.xml  { render :xml => @room, :status => :created, :location => @room }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @room.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rooms/1
  # PUT /rooms/1.xml
  def update
    @room = Room.find(params[:id])
    if params[:performance].present?
      if a = params[:performance].delete(:agent)
        covi_room_role = Role.find_by_name_and_stage_type "COVI", "Room"
        klass, id = a.split("-", 2)
        performance = Performance.new
        performance.stage_id = @room.id
        performance.stage_type = 'Room'
        performance.role_id = covi_room_role.id
        performance.agent_id = id
        performance.agent_type = klass.classify
        performance.save
      end
    end

    respond_to do |format|
       room_aux= Room.new(params[:room])
	@room.reevaluation=false
	@room.bandera_mail=false
	if( room_aux.equipment != nil)
		if ((room_aux.equipment != @room.equipment) || (room_aux.devices != @room.devices) || (room_aux.bandwidth != @room.bandwidth) || (room_aux.light_type != @room.light_type))
		   @room.bandera_mail=true
		   @room.reevaluation=true
		end
	end
      if @room.update_attributes(params[:room])
        flash[:notice] = I18n.t('room.message.successfully_updated');
    
          if current_user.superuser?
            format.html {redirect_to("/manage/rooms")} 
         else
            format.html {redirect_to("/spaces/#{@room.space.permalink}/rooms")}
	   end	
       
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @room.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.xml
#  def destroy
#    @room = Room.find(params[:id])
#    @room.destroy

#    respond_to do |format|
#      format.html { redirect_to(rooms_url) }
#      format.xml  { head :ok }
#    end
#  end

  def update_list_space
    # updates list rooms based on country selected
    spaces = Spaces.find_all_by_country(params[:country])
    render :partial => 'list_spaces', :locals => {:spaces => spaces} 
  end

  def asign_covi
    @main_space = current_user.main_space
    @room = Room.find(params[:id])
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rooms }
    end
  end

end

class McusController < ApplicationController
  # GET /mcus
  # GET /mcus.xml
  def index
    @space = Space.find_by_permalink(params[:space_id])
    @mcus = @space.mcus

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mcus }
    end
  end

  # GET /mcus/1
  # GET /mcus/1.xml
  def show
    @mcu = Mcu.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mcu }
    end
  end

  # GET /mcus/new
  # GET /mcus/new.xml
  def new
    @space = Space.find_by_permalink(params[:space_id])
    @mcu = Mcu.new
    @mcu.space = @space
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mcu }
    end
  end

  # GET /mcus/1/edit
  def edit
    @mcu = Mcu.find(params[:id])
    @space = @mcu.space 
  end

  # POST /mcus
  # POST /mcus.xml
  def create
    @mcu = Mcu.new(params[:mcu])
    @space = Space.find_by_permalink(params[:space_id])
	
    respond_to do |format|
      if @mcu.save
        flash[:notice] = t('mcu.created_successfully')
        format.html { redirect_to(space_mcus_url) }
        format.xml  { render :xml => @mcu, :status => :created, :location => @mcu }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mcu.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mcus/1
  # PUT /mcus/1.xml
  def update
    @mcu = Mcu.find(params[:id])
     @space = Space.find_by_permalink(params[:space_id])
	 
    respond_to do |format|
      if @mcu.update_attributes(params[:mcu])
        flash[:notice] = t('mcu.updated_successfully')
#        format.html { redirect_to(@mcu) }
        format.html { redirect_to(space_mcus_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mcu.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mcus/1
  # DELETE /mcus/1.xml
  def destroy
    @mcu = Mcu.find(params[:id])
    @mcu.destroy

    respond_to do |format|
	  if params[:type] == nil
      	format.html { redirect_to(space_mcus_url) }
	  else
	  	format.html {redirect_to("/manage/mcus")}
	  end 	
      format.xml  { head :ok }
    end
  end
end

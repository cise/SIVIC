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

class SpacesController < ApplicationController
  include ActionController::StationResources
  
  before_filter :space
  
  authentication_filter :only => [:new, :create]
  authorization_filter :read,   :space, :only => [:show]
  authorization_filter :update, :space, :only => [:edit, :update]
  authorization_filter :delete, :space, :only => [:destroy, :enable]

  set_params_from_atom :space, :only => [ :create, :update ]

  # GET /spaces
  # GET /spaces.xml
  # GET /spaces.atom
  def index
    if params[:space_id] && params[:space_id]!= "all" && params[:space_id]!="my" && params[:space_id]!=""
      redirect_to space_path(Space.find_by_permalink(params[:space_id]))
      return
    end
    #@spaces = Space.find(:all, :order => 'name ASC')
    if params[:cap]
      @spaces = Space.paginate :page => params[:page], :order => 'name ASC', :conditions => ['name like ?', "#{params[:cap]}%"]
    else
      @spaces = Space.paginate :page => params[:page], :order => 'name ASC'      
    end

    @private_spaces = @spaces.select{|s| !s.public?}
    @public_spaces = @spaces.select{|s| s.public?}
    if @space
       session[:current_tab] = "Spaces" 
    end
    if params[:manage]
      session[:current_tab] = "Manage" 
      session[:current_sub_tab] = "Spaces"
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spaces }
      format.atom
    end
  end
  
  # GET /spaces/1
  # GET /spaces/1.xml
  # GET /spaces/1.atom
  def show  
    @news_position = (params[:news_position] ? params[:news_position].to_i : 0) 
    @news = @space.news.find(:all, :order => "updated_at DESC")
    @news_to_show = @news[@news_position]
    @posts = @space.posts
    @lastest_posts=@posts.not_events().find(:all, :conditions => {"parent_id" => nil}, :order => "updated_at DESC").first(3)
    @lastest_users=@space.stage_performances.sort {|x,y| y.created_at <=> x.created_at }.first(3).map{|performance| performance.agent}
    @upcoming_events=@space.events.find(:all, :order => "start_date ASC").select{|e| e.start_date && e.start_date.future?}.first(5)
    @performance=Performance.find(:all, :conditions => {:agent_id => current_user, :stage_id => @space, :stage_type => "Space"})
    @current_events = (Event.in(@space).all :order => "start_date ASC").select{|e| e.start_date && !e.start_date.future? && e.end_date.future?}
    respond_to do |format|
      if @space.pending_join_requests_for?(current_user)
        flash.now[:notice] = t('space.join_pending', :space => @space.name)
      end 
      format.html{
        if request.xhr?
          render :partial=>"last_news"
        end
      }
      format.xml  { render :xml => @space }
      format.atom
    end
  end
  
  # GET /spaces/new
  def new
    if params[:parent]
      @parent = Space.find(params[:parent])      
    end

    respond_to do |format|
      format.html{
          if request.xhr?
            render :partial=>"new"
          end  
      }
    end
  end
  
  # GET /spaces/1/edit
  def edit
    #@users = @space.actors.sort {|x,y| x.name <=> y.name }
    @performances = space.stage_performances.sort {|x,y| x.agent.name <=> y.agent.name }
    @roles = Space.roles
  end
  
  
  # POST /spaces
  # POST /spaces.xml 
  # POST /spaces.atom
  # {"space"=>{"name"=>"test space", "public"=>"1", "description"=>"<p>this is the description of the space</p>"}
  def create
    unless logged_in?
      if params[:register]
        cookies.delete :auth_token
        @user = User.new(params[:user])
        unless @user.save_with_captcha
          message = ""
          @user.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          render :action => :new, :layout => "frontpage"
          return
        end
      end
        
      self.current_agent = User.authenticate_with_login_and_password(params[:user][:email], params[:user][:password])
      unless logged_in?
          flash[:error] = t('error.credentials')
          render :action => :new, :layout => "frontpage"
          return
      end
    end
      
    @space = Space.new(params[:space])
    create_group
    unless @group.valid?
      message = ""
      @group.errors.full_messages.each {|msg| message += msg + "  <br/>"}
      flash[:error] = message
      render :action => :new, :layout => "application"
      return

    end
    @group.space = @space
    respond_to do |format|
      if @space.save && @group.save
        flash[:success] = t('space.created')
        vnoc_user = User.find(:first, :conditions => ["login = 'vnoc'"] )
        if current_user != vnoc_user
          @space.stage_performances.create(:agent => vnoc_user, :role => Space.role('Admin'))
        end
        @space.stage_performances.create(:agent => current_user, :role => Space.role('Admin'))
        format.html { redirect_to :action => "show", :id => @space  }
        format.xml  { render :xml => @space, :status => :created, :location => @space }
        format.atom { 
          headers["Location"] = formatted_space_url(@space, :atom )
          render :action => 'show',
                 :status => :created
        }
      else
        format.html {
          message = ""
          @space.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          render :action => :new, :layout => "application" 
          }
        #format.html { redirect_to :action => "new"}
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @space.errors.to_xml, :status => :bad_request }
      end
      
    end    
  end
  
  
  
  # PUT /spaces/1
  # PUT /spaces/1.xml
  # PUT /spaces/1.atom
  def update
    if @space.update_attributes(params[:space]) 
      respond_to do |format|
        format.html { 
          flash[:success] = t('space.updated')
          redirect_to request.referer
        }
        format.atom { head :ok }
        format.js{
          if params[:space][:name]
            @result = "window.location=\"#{edit_space_path(@space)}\";"
            render "result.js"
          elsif params[:space][:description]
            @result=params[:space][:description]
            render "result.js"
          elsif params[:space][:skin]
            @result = "window.location=\"#{edit_space_path(@space)}\";"
            render "result.js"
          else
            render "update.js"
          end
        }
      end
    else
      respond_to do |format|
        flash[:error] = t('error.change')
        format.js {
        @result = "$(\"#admin_tabs\").before(\"<div class=\\\"error\\\">" + t('.error.not_valid') +  "</div>\")"
        }
        format.html { 
        redirect_to edit_space_path() }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @space.errors.to_xml, :status => :not_acceptable }
      end      
    end
  end
  
  
  # DELETE /spaces/1
  # DELETE /spaces/1.xml
  # DELETE /spaces/1.atom
  def destroy
    @space_destroy = Space.find_with_param(params[:id])
    @space_destroy.disable
    respond_to do |format|
      format.html {
        if request.referer.present? && request.referer.include?("manage") && current_user.superuser?
          flash[:notice] = t('space.disabled')
          redirect_to manage_spaces_path
        else
          flash[:notice] = t('space.deleted')
          redirect_to(spaces_url)
        end
      }
      format.xml  { head :ok }
      format.atom { head :ok }
    end
  end
  
  def create_group
    if params[:mail].blank?
      @space.mailing_list_for_group = ""
    end
      @group = Group.new(:name => @space.emailize_name, :mailing_list => @space.mailing_list_for_group)
      @group.users << @space.users(:role => "admin")
      @group.users << @space.users(:role => "user")
  end

  def enable
    
    unless @space.disabled?
      flash[:notice] = t('space.error.enabled', :name => @space.name)
      redirect_to request.referer
      return
    end
    
    @space.enable
    
    flash[:success] = t('space.enabled')
    respond_to do |format|
      format.html {
          redirect_to manage_spaces_path
      }
      format.xml  { head :ok }
      format.atom { head :ok }
    end
  end
  
  def video
        respond_to do |format|
          format.html
          format.xml  { render :xml => @space }
          format.atom
        end
      end
  def show_room
      @rooms = Room.find(:all, :order => "name")
      respond_to do |format|
          format.html
          format.xml  { render :xml => @space }
          format.atom
      end
  end
  
  def update_list_space
    # updates list spaces based on country selected
    @country = params[:country]
    @spaces = Space.spaces_by_country(@country)

    render :partial => 'spaces/list_spaces', :locals => { :spaces => @spaces }
  end
  
  private
  
  def space
    if params[:action] == "enable"
      @space ||= Space.find_with_disabled_and_param(params[:id])
    else
      @space ||= Space.find_with_param(params[:id])  
    end
  end
end

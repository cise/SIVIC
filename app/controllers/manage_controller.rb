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

class ManageController < ApplicationController
  authorization_filter :manage, :current_site  
  
  def users
    @users=User.find_with_disabled(:all,:order => "login")
    @site_roles = Site.roles
  end

  def spaces
    @spaces=Space.find_with_disabled(:all, :order => "country, name")
 
    if params[:country] != nil && params[:country] != ""
	@spaces = @spaces.select {|s| s.country == params[:country] }
       @country = params[:country]
    end    
  end
  
  def spam
    @spam_events= Event.find(:all, :conditions => {:spam => true})
    @spam_posts = Post.find(:all, :conditions => {:spam => true})
  end

  def rooms
    @rooms = Room.find(:all, :order => "country, name").select {|r| !r.space.nil?}
  end
  
  def mcus
    @mcus = Mcu.find(:all)
  end
  
  def edit_room
    #@main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @room = Room.find(params[:id])
  end
  
  def edit_mcu
    #@main_space = current_user.agent_performances.select {|x| x.stage_type = 'Space'}.first.stage
    @mcu = Mcu.find(params[:id])
	@space = @mcu.space
  end
  
  def update_mcu
    @mcu = Mcu.find(params[:id])
    @space = Space.find_by_permalink(params[:space_id])
	 
    respond_to do |format|
      if @mcu.update_attributes(params[:mcu])
        flash[:notice] = t('mcu.updated_successfully')
		format.html {redirect_to("/manage/mcus")}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_mcu" }
        format.xml  { render :xml => @mcu.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def countries
    @countries = Country.all
  end
  
end

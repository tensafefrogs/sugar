class NotificationsController < ApplicationController
	requires_authentication
	requires_user
	
	helper :all
	
	def index
		@notifications = @current_user.notifications
	end
end

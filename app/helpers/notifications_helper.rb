module NotificationsHelper
	# Sends a notification
	def send_notification(user, type, params={}, link=nil)
		params.symbolize_keys!
		user.notifications.create(:notification_type => type.to_s, :notification_attributes => params, :link => link)
	end
	
	# Render notification
	def render_notification(notification)
		notification_template = File.join(RAILS_ROOT, "app/views/notifications/templates/#{notification.notification_type}.erb")
		if File.exists?(notification_template)
			render :template => notification_template
		else
			raise "File not found: #{notification_template}"
		end
	end
end

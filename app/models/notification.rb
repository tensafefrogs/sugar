class Notification < ActiveRecord::Base
	belongs_to :user
	serialize :notification_attributes, Hash
	validates_presence_of :notification_type, :notification_attributes, :user_id
end

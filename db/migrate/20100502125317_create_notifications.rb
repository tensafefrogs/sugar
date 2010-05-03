class CreateNotifications < ActiveRecord::Migration
	def self.up
		create_table :notifications do |t|
			t.belongs_to :user
			t.string     :notification_type
			t.text       :notification_attributes
			t.string     :link
			t.boolean    :seen, :null => false, :default => false
			t.timestamps
		end
	end

	def self.down
		drop_table :notifications
	end
end

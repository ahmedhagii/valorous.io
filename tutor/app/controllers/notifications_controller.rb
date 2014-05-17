class NotificationsController < ApplicationController

	# [View Courses - Stroy 2.10]
	# This action renders a list of all notifications belonging to 
	#	the current user.
	# Parameters:
	#	current_lecturer: The current signed in lecturer
	#	current_student: the current signed in student
	#	current_teaching_assistant: the current signed in teaching assistant
	# Returns: 
	#	@new_notifications: A list of all the user's unseen notifications
	#	@old_notifications: A list of all the user's seen notifications
	# Author: Muhammad Mamdouh
	def index
		if current_lecturer
			@user = current_lecturer
		elsif current_teaching_assistant
			@user = current_teaching_assistant
		else @user = current_student
		end
		@new_notifications = []
		@old_notifications = []
		@user.notifications.where("seen = 't'").each do |notification|
			@old_notifications << notification.clone
		end	
		@user.notifications.where("seen = 'f'").each do |notification|
			@new_notifications << notification.clone
		end		
		@user.notifications.where("seen = 'f'").each do |notification|
			notification.seen = 't'
			notification.save
		end	
	end

	# [Notification sending-story 2.9]
	# Description: Displays Notifications of the user
	# Parameters:
	#	@notifications: The current notifications of the current user
	# Returns: The view of the notifications
	# Author: Ahmed Atef
	def index
		if lecturer_signed_in?
			@notifications = Lecturer.find(params[:id]).notifications.order("created_at desc")
		elsif teaching_assistant_signed_in?
			@notifications = TeachingAssistant.find(params[:id])
				.notifications.order("created_at desc")
		else
			@notifications = Student.find(params[:id]).notifications.order("created_at desc")
		end
	end 

end
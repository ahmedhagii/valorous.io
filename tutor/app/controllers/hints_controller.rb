class HintsController < ApplicationController

  	# [View hints and tips-Story 4.22]
	# It fetches from database all the previous hints.
	# Parameters: 
	#	@hints: All the previous hints that had been entered before.
	#	@hints_check: All the previous hints that had been entered before to check if it is a hint or a tip.
	# Returns: none
	# Author: Nadine Adel
	def index
		session[:model_answer_id] = params[:model_answer_id]
		@model_answer = ModelAnswer.find_by_id(session[:model_answer_id])
		@hints = Hint.get_hints @model_answer.id
	end
	
	# [Edit helping hints - Story 4.13 ]
	# This action creates the form and retrives the data of the selected problem 
	#	to be being edited
	# Parameters:
	#	ID of the hint  
	# Returns: none
	# Author: Mimi
	def edit
		session[:hint_id] = params[:hint_id]
		@hint = Hint.find_by_id(params[:hint_id])
	end	

	# [Edit helping hints - Story 4.13 ]
	# This action takes the passed parameters from 
	#	the creation form, edits a Hint record
	#	which assigned  to the respective problem. If the 
	#	edit fails the user is redirected to the form
	#	with a "Failed" message.
	# Parameters:
	#	hint_params[]: A list that has all fields entered by the user to in the
	#		edit_hint form
	# Returns: 
	#	flash[:notice]: A message indicating the success or failure of the edit
	# Author: Mimi
	def update
		@hint = Hint.find(session[:hint_id])
		if hint_params_edit[:message] != @hint.message ||
			hint_params_edit[:submission_counter] != @hint.submission_counter
			if @hint.message != hint_params_edit[:message]
				flash.keep[:notice] = "Content has changed"
			elsif @hint.submission_counter != hint_params_edit[:submission_counter]
				flash.keep[:notice] = "Time has changed"
			end
			begin
				if @hint.update_attributes(hint_params_edit)
					respond_to do |format|
						format.js
						format.html {redirect_to :action => "edit", :format => :js,
							:hint_id => @hint.id, :track_id => session[:track_id]}
					end
				else
					@hint = Hint.find_by_id(params[:hint_id])
					respond_to do |format|
						format.js
						format.html {redirect_to :action => "edit", :format => :js,
							:hint_id => @test_case.id, :track_id => session[:track_id]}
					end
				end
			rescue
				@hint = Hint.find_by_id(session[:hint_id])
				respond_to do |format|
					format.js
					format.html {redirect_to :action => "edit", :format => :js,
					:hint_id => @test_case.id, :track_id => session[:track_id]}
				end
			end
		end
	end

	# [Add hint - Story 4.10]
	# Allows Lecturer/TA to create a hint to help the student_users while solving a problem
	# Parameters: none
	# Returns:
	#	@hint: a new created hint to specific answer
	# Author: Ahmed Osam
	def new
		@hint = Hint.new
		session[:track_id] = params[:track_id]
		if(@hint == nil)
			session[:model_answer_id] = params[:model_answer_id]
			@model_answer = ModelAnswer.find_by_id(session[:model_answer_id])
		end
	end

	# [Add hint - Story 4.10]
	# Allows Lecturer/TA to create a hint to help the student_users while solving a problem
	# Parameters: 
	#	message: is the content of the hint
	#	time: is a countdown timer that hint will appear after it ends
	#	model_answer_id: is the id of the answer the hint related to
	# Returns:
	#	@hint: a new created hint to specific answer
	# Author: Ahmed Osam
	def create
		@hint = Hint.new
		@model_answer = ModelAnswer.find_by_id(session[:model_answer_id])
		@hint.message = hint_params[:message]
		@hint.time = 0
		@hint.category = false
		@hint.model_answer_id = session[:model_answer_id]
		@hint.submission_counter = hint_params[:submission_counter]
		if lecturer_signed_in?
			@hint.owner_type = "lecturer"
			@hint.owner_id = current_lecturer.id
		elsif teaching_assistant_signed_in?
			@hint.owner_type = "teaching assistant"
			@hint.owner_id = current_teaching_assistant.id
		end
		if @hint.save
			redirect_to :controller => 'hints', :action => 'new',
			:model_answer_id => session[:model_answer_id], 
			:problem_id => session[:problem_id],
			:track_id => session[:track_id]
		else
			render :action => 'new'
		end
	end


 	# [Edit helping hints - Story 4.13 ]
	# Description: 
	#	take the parameters from the from
	# Parameters: none
	# Returns:
	#	Hash of paramas 
	# Author: Mimi
	private
		def hint_params
			params.require(:hint).permit(:message, :submission_counter, :id)
		end
end


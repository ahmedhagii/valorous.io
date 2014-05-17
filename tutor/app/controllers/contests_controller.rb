class ContestsController < ApplicationController
	before_action :validate_timer, :except => ['new', 'create', 'edit', 'update', 'destroy']

	# [Create Contest - Story 5.16]
	# Defines a new Contest instance for the form in the new view
	# Parameters: none
	# Returns: none
	# Author: Amir George
	def new
		if student_signed_in?
			render ('public/404')
		end
		if(@new_contest == nil)
			@new_contest = Contest.new
		end
	end

	# [Create Contest - Story 5.16]
	# Takes the params submitted from new form and inserts record
	# 	in database accordingly
	# Parameters: none
	# Returns: none
	# Author: Amir George
	def create
		if student_signed_in?
			render ('public/404')
		end
		@new_contest  = Contest.new
		@new_contest.title = contest_params[:title]
		unless contest_params[:course] == ""
			@new_contest.course = Course.find_by_name(contest_params[:course])
		end
		@new_contest.description = contest_params[:description]
		@new_contest.start_time = DateTime.new(contest_params["start_time(1i)"].to_i,
			contest_params["start_time(2i)"].to_i, contest_params["start_time(3i)"].to_i,
			contest_params["start_time(4i)"].to_i, contest_params["start_time(5i)"].to_i)
		@new_contest.end_time = DateTime.new(contest_params["end_time(1i)"].to_i,
			contest_params["end_time(2i)"].to_i, contest_params["end_time(3i)"].to_i,
			contest_params["end_time(4i)"].to_i, contest_params["end_time(5i)"].to_i)
		if lecturer_signed_in?
			@new_contest.owner = current_lecturer
		elsif teaching_assistant_signed_in?
			@new_contest.owner = current_teaching_assistant
		end

		if @new_contest.save
			flash[:success_creation]= "Contest added."
			redirect_to :action => 'index'
		else
			render :action=>'new'
		end
	end

	# [Create Contest - Story 5.16]
	# Defines contest parameters to be permitted from the form view
	# Parameters: none
	# Returns: none
	# Author: Amir George
	private
		def contest_params
			params.require(:contest).permit(:title, :description, :course, :start_time, :end_time)
		end
	
	private

		# [Contest Timer - Story 5.28]
		# Checks the state of the timer based on the date and time of a specific contest
		# 	and affecting the behaviour of the timer and the message that accompanies it
		# 	based on the timing of the contest. If the contest didn't start yet, the timer
		# 	will be set to countdown till the start of the contest and the message appearing
		# 	will be 'Contest starts in'. If the contest has started, the timer will be set
		# 	to countdown till the end of the contest and the message will be 'Contest ends in'.
		# 	If the contest has ended, the timer will disappear and the message will be
		# 	'Contest has finished!'.
		# Parameters:
		# 	params[:id]: an Integer containing the id of a specific contest to have its timer.
		# Returns:
		# 	@timer: a String representation of a DateTime object representing the date
		# 		and the time of the contest that will be used by the timer.
		# 	@message: a String containing the message accompanying the timer.
		# 	@del: a Boolean indicating if the contest has finished which affects the
		# 		behaviour of the timer; whether to remove it or not.
		# Author: Khaled Helmy
		def validate_timer
			@contest = Contest.find(params[:id])
			contest_start = @contest.start_time
			contest_end = @contest.end_time
			current = DateTime.now
			if current < contest_start
				@timer = contest_start
				@message = "Contest starts in"
				@del = false
			elsif current <= contest_end
				@timer = contest_end
				@message = "Contest ends in"
				@del = false
			else
				@timer = nil
				@message = "Contest has finished!"
				@del = true
			end
		end

end

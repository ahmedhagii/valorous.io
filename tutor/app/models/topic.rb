class Topic < ActiveRecord::Base

	#Elasticsearch
	include Tire::Model::Search
	include Tire::Model::Callbacks
		
	#Validations
	validates :title, :description, presence: true
	validates :title, :description, uniqueness: true

	#Relations
	has_many :tracks, dependent: :destroy
	belongs_to :course
	belongs_to :owner, class_name: "Lecturer", foreign_key: :lecturer_id

	#Methods

	# [Advanced Search - Story 1.23]
	# search for topics
	# Parameters: hash of search options
	# Returns: A hash with search results according to the keyword and other options
	# Author: Ahmed Elassuty
	def self.search(params)
		if params[:keyword].present?
			case params[:options]
				when "exactly match"
					tire.search do
						query { string "title:#{params[:keyword]}" }
					end
				when "includes"
					tire.search do
						query { string "title:*#{params[:keyword]}*" }
					end
				when "starts with"
					tire.search do
						query { string "title:#{params[:keyword]}*" }
					end
				when "ends with"
					tire.search do
						query { string "title:*#{params[:keyword]}" }
					end
			end
		end
	end
end

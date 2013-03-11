class Micropost < ActiveRecord::Base
	attr_accessible :content
	belongs_to :user
	validates :user_id, presence: true
	validates :content, presence: true, length: { maximum: 140 }
	default_scope order: 'microposts.created_at DESC'

	def self.from_users_followed_by(user)
		followed_user_ids = "SELECT followed_id FROM relationships
		WHERE follower_id = :user_id"
		where("user_id IN (#{followed_user_ids}) OR user_id = :user_id OR in_reply_to = :user_id",
			user_id: user.id)
	end

	before_save :find_reply_to_user

	def find_reply_to_user
		first_word = self.content.split.first
		if first_word.starts_with? "@"
			user_name = first_word[1..-1]
			user = User.find_by_name(user_name)
			self.in_reply_to = user.id
		end
	end
end
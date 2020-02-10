class Claim < ApplicationRecord
	belongs_to :client
	belongs_to :donation

	validates :client_id, presence: true
	validates :donation_id, presence: true
end

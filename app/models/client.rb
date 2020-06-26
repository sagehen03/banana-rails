class Client < ActiveRecord::Base
	has_secure_password
  
	has_many :claims
    
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, presence: true
  validates :password, format: { with: /\A(?=.*[a-zA-Z])(?=.*[0-9]).{8,40}\z/}
  validates_presence_of :first_name, :last_name
  #validates :address_street, presence: false         # commented out for pre-alpha
  #validates :address_city, presence: false           # TODO: change it to presence: true after pre-alpha
  #validates :address_state, presence: false          # TODO: change it to presence: true after pre-alpha
  #validates :address_zip, presence: true             # commented out for pre-alpha
  #validates :account_status, presence: true          # commented out for pre-alpha
  #validates :ethnicity, presence: false              # TODO: change it to presence: true after pre-alpha
  #validates :gender, presence: false                 # TODO: change it to presence: true after pre-alpha
end



 






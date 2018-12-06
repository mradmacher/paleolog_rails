class User < ActiveRecord::Base
  class NotAuthorized < StandardError
  end
  class NotInAccount < StandardError
  end
  class NotInResearch < StandardError
  end

	# attr_accessible :name, :email, :login, :password, :password_confirmation
	# attr_accessible :admin, :as => :admin

  has_many :comments
  has_many :account_participations
  has_many :accounts, :through => :account_participations
  has_many :research_participations
  has_many :sections, :through => :research_participations

  HUMANIZED_ATTRIBUTES = {
    :name => 'Name',
    :email => 'E-mail address',
    :password => 'Password'
  }
  LOGIN_MIN_LENGTH = 5
  LOGIN_MAX_LENGTH = 20
  LOGIN_RANGE = LOGIN_MIN_LENGTH..LOGIN_MAX_LENGTH
  LOGIN_SIZE = 20
  NAME_MIN_LENGTH = 2
  NAME_MAX_LENGTH = 20
  PASSWORD_MIN_LENGTH = 4
  PASSWORD_MAX_LENGTH = 40
  EMAIL_MAX_LENGTH = 50
  NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH
  PASSWORD_RANGE = PASSWORD_MIN_LENGTH..PASSWORD_MAX_LENGTH
  EMAIL_SIZE = 20
  NAME_SIZE = 20
  PASSWORD_SIZE = 20

  validates_confirmation_of :password
  validates_presence_of :password
  validates_length_of :password, :within => PASSWORD_RANGE
  validates_uniqueness_of :name, :login
  validates_length_of :login, :within => LOGIN_RANGE
  validates_length_of :name, :within => NAME_RANGE
  validates_length_of :email, :maximum => EMAIL_MAX_LENGTH
  validates_presence_of :login
  validates_presence_of :name
  validates_format_of :email,
    :with => /\A[A-Z0-9._-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}\z/i,
    :unless => Proc.new { |a| a.email.blank? }

  def author_of?( object )
    id == object.user_id
  end

end

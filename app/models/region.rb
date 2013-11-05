class Region < ActiveRecord::Base
	has_many :wells

	NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH
  NAME_SIZE = 20

	validates :name, :presence => true, :length => { :within => NAME_RANGE }
  validates :name, :uniqueness => true

  before_destroy do
    unless self.wells.empty?
      errors[:base] << I18n.t( 'activerecord.errors.models.region.wells.exist' )
      return false
    end
  end

  def to_param
    "#{self.id},#{self.name.parameterize}"
  end
end

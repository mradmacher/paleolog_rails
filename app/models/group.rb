class Group < ActiveRecord::Base
  has_many :specimens
  has_many :fields

  NAME_MIN_LENGTH = 1
  NAME_MAX_LENGTH = 20
  NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH

  validates :name, :length => { :within => NAME_RANGE }, :presence => true, :uniqueness => true
end

class Choice < ActiveRecord::Base
  belongs_to :field
  has_many :features

  NAME_MAX_LENGTH = 50

  validates :name, 
    :length => { :maximum => NAME_MAX_LENGTH }, 
    :presence => true, 
    :uniqueness => { :scope => :field_id }
  validates :field_id, :presence => true

  before_destroy do
    if Feature.where( choice_id: self.id ).exists?
      errors[:base] << I18n.t( 'activerecord.errors.models.choice.feature.exists' )
      return false
    end
  end
end



class Field < ActiveRecord::Base
  belongs_to :group
  has_many :choices, :dependent => :destroy

  NAME_MAX_LENGTH = 50

  validates :name,
    :length => { :maximum => NAME_MAX_LENGTH },
    :presence => true,
    :uniqueness => { :scope => :group_id }
  validates :group_id, :presence => true

  before_destroy do
    if Feature.joins( :choice ).where( choices: { field_id: self.id } ).exists?
      errors[:base] << I18n.t( 'activerecord.errors.models.field.feature.exists' )
      false
    end
  end
end


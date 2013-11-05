class Feature < ActiveRecord::Base
  belongs_to :specimen
  belongs_to :choice

  validates_presence_of :choice_id
  validates_uniqueness_of :choice_id, :scope => :specimen_id
  validates_presence_of :specimen_id 
  validate :specimen_and_choice_group
  validate :specimen_and_choice_field

  private
  def specimen_and_choice_group
    self.errors[:choice_id] << I18n.t( 'activerecord.errors.models.feature.attributes.choice_id.invalid_group' ) if
      self.choice && self.specimen && self.choice.field.group != self.specimen.group
  end

  def specimen_and_choice_field
    self.errors[:choice_id] << I18n.t( 'activerecord.errors.models.feature.attributes.choice_id.taken' ) if
      self.choice && 
      self.specimen && 
      (self.new_record??  
        Feature.joins( :choice ).where( specimen_id: self.specimen_id, choices: { field_id: self.choice.field_id } ).exists? :
        Feature.joins( :choice ).where( specimen_id: self.specimen_id, choices: { field_id: self.choice.field_id } ).
        where( 'features.id <> ?', self.id ).exists?)
  end
end



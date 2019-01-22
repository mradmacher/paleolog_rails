class Specimen < ActiveRecord::Base
  has_many :images, :dependent => :destroy
  has_many :occurrences
  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :group
  has_many :countings, :foreign_key => 'marker_id'
  has_many :features, :dependent => :destroy

  accepts_nested_attributes_for :features

  NAME_MIN_LENGTH = 1
  NAME_MAX_LENGTH = 100
  NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH
  NAME_SIZE = 58
  ENVIRONMENTAL_PREFERENCES_COLS = 80
  ENVIRONMENTAL_PREFERENCES_ROWS = 4
  DESCRIPTION_COLS = 80
  DESCRIPTION_ROWS = 10
  DESCRIPTION_MAX_LENGTH = 4096
  ENVIRONMENTAL_PREFERENCES_MAX_LENGTH = 4096

  validates :name, :length => { :within => NAME_RANGE }, :presence => true, :uniqueness => { :scope => :group_id }
  validates :group_id, :presence => true
  validates :description, :length => { :maximum => DESCRIPTION_MAX_LENGTH }
  validates :environmental_preferences, :length => { :maximum => ENVIRONMENTAL_PREFERENCES_MAX_LENGTH }
  validate :feature_group

  before_destroy do
    unless self.occurrences.empty?
      errors[:base] << I18n.t('activerecord.errors.models.specimen.occurrence.exists')
      false
    end
  end

  def field_features
    result = {}
    group.fields.each do |field|
      result[field] = features.select{ |f| f.choice.field_id == field.id }.first
    end
    result
  end

  def self.search(params = {})
    specimens = Specimen.all
    specimens = specimens.where(group_id: params[:group_id]) unless params[:group_id].blank?
    specimens = specimens.joins(occurrences: :sample).where('samples.section_id' => params[:section_id]) unless params[:section_id].blank?
    specimens = specimens.joins(:features).where('features.choice_id' => params[:choice_id]) unless params[:choice_id].blank?
    specimens = specimens.joins(:occurrences).
      where('occurrences.counting_id' => params[:counting_id]).uniq unless params[:counting_id].blank?
    unless params[:choice_ids].blank?
      choice_ids = params[:choice_ids].delete_if { |c| c.blank? }
      unless choice_ids.empty?
        specimen_ids = Specimen.joins(:features).where('features.choice_id' => choice_ids).
          select( 'specimens.id, count(features.id)').
          group('specimens.id').having('count(features.id) >= ?', choice_ids.size ).map(&:id)
        specimens = specimens.where(id: specimen_ids)
      end
    end
    specimens
  end

  private

  def feature_group
    if changes.keys.include? 'group_id'
      errors[:group_id] << I18n.t( 'activerecord.errors.models.specimen.attributes.group_id.features' ) if
        Feature.where( specimen_id: self.id ).exists?
    end
  end
end

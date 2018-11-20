class Specimen < ActiveRecord::Base
  has_many :images, :dependent => :destroy
  has_many :occurrences, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :group
  has_many :countings, :foreign_key => 'marker_id'
  has_many :features, :dependent => :destroy

  accepts_nested_attributes_for :features

  NAME_MIN_LENGTH = 1
  NAME_MAX_LENGTH = 50
  NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH
  NAME_SIZE = 40
  AGE_COLS = 60
  AGE_ROWS = 4
  DESCRIPTION_COLS = 60
  DESCRIPTION_ROWS = 10
  COMPARISON_COLS = 60
  COMPARISON_ROWS = 8
  RANGE_COLS = 60
  RANGE_ROWS = 4
  DESCRIPTION_MAX_LENGTH = 2047
  AGE_MAX_LENGTH = 2047
  COMPARISON_MAX_LENGTH = 2047
  RANGE_MAX_LENGTH = 2047

  validates :name, :length => { :within => NAME_RANGE }, :presence => true, :uniqueness => { :scope => :group_id }
  validates :group_id, :presence => true
  validates :description, :length => { :maximum => DESCRIPTION_MAX_LENGTH }
  validates :age, :length => { :maximum => AGE_MAX_LENGTH }
  validates :comparison, :length => { :maximum => COMPARISON_MAX_LENGTH }
  validates :range, :length => { :maximum => RANGE_MAX_LENGTH }
  validate :feature_group

  def field_features
    result = {}
    group.fields.each do |field|
      result[field] = features.select{ |f| f.choice.field_id == field.id }.first
    end
    result
  end

  def self.search( params = {} )
    specimens = Specimen.all
    specimens = specimens.where( :group_id => params[:group_id] ) unless params[:group_id].blank?
    specimens = specimens.joins( :occurrences ).
      where( 'occurrences.counting_id' => params[:counting_id] ).uniq unless params[:counting_id].blank?
    specimens = specimens.joins( :features ).where( 'features.choice_id' => params[:choice_id] ) unless params[:choice_id].blank?
    unless params[:choice_ids].blank?
      choice_ids = params[:choice_ids].delete_if { |c| c.blank? }
      unless choice_ids.empty?
        specimen_ids = Specimen.joins( :features ).where( 'features.choice_id' => choice_ids ).
          select( 'specimens.id, count(features.id)').
          group('specimens.id').having( 'count(features.id) >= ?',
          choice_ids.size ).map(&:id)
        specimens = specimens.where( id: specimen_ids )
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

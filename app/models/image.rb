class Image < ActiveRecord::Base
  EF_MAX_LENGTH = 8

  belongs_to :specimen
  belongs_to :sample
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_attached_file :image,
      :styles => { :medium => ["600x600>", :jpg], :thumb => ["100x100>", :jpg] },
      :path => ':rails_root/public/system/:class/:attachment/:id_partition/:style.:extension',
      :url => '/system/:class/:attachment/:id_partition/:style.:extension'

  validates :specimen_id, :presence => true
  validates_presence_of :image_file_name, :on => :create
  validates_length_of :ef, :maximum => EF_MAX_LENGTH
  validates_attachment :image, content_type: {
    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  }

  def name
    specimen.name
  end
end

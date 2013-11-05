class MigrateOthersToSpecimens < ActiveRecord::Migration
  class Other < ActiveRecord::Base
    self.record_timestamps = false
    has_many :images, :as => :imageable
    has_many :occurrences, :as => :specimen
    has_many :comments, :as => :commentable
  end
  class Specimen < ActiveRecord::Base
    OTHER = 2
    self.record_timestamps = false
    has_many :images, :as => :imageable
    has_many :occurrences, :as => :specimen
    has_many :comments, :as => :commentable
  end
  class Image < ActiveRecord::Base
    self.record_timestamps = false
    belongs_to :imageable, :polymorphic => true
  end
  class Occurrence < ActiveRecord::Base
    self.record_timestamps = false
    belongs_to :specimen, :polymorphic => true
  end
  class Comment < ActiveRecord::Base
    self.record_timestamps = false
    belongs_to :commentable, :polymorphic => true
  end

  def self.up
    i = 0
    say "Total: #{Other.count}"
    Other.all.each do |other|
      Specimen.transaction do 
        specimen = Specimen.find_or_initialize_by_name_and_group( :name => other.name,
          :group => Specimen::OTHER )
        specimen.verified = other.verified
        specimen.description = other.description
        specimen.created_at = other.created_at
        specimen.updated_at = other.updated_at
        specimen.save
        Image.find_all_by_imageable_id_and_imageable_type( other.id, 'Other' ).each do |image|
          image.imageable_id = specimen.id
          image.imageable_type = 'Specimen'
          image.save
        end
        Occurrence.find_all_by_specimen_id_and_specimen_type( other.id, 'Other' ).each do |occurrence|
          occurrence.specimen_id = specimen.id
          occurrence.specimen_type = 'Specimen'
          occurrence.save
        end
        Comment.find_all_by_commentable_id_and_commentable_type( other.id, 'Other' ).each do |comment|
          comment.commentable_id = specimen.id
          comment.commentable_type = 'Specimen'
          comment.save
        end
        other.destroy
        i += 1
        say "#{other.name} migrated"
      end
    end
    say "Migrated: #{i}"
  end

  def self.down
    i = 0
    say "Total: #{Specimen.where( :group => Specimen::OTHER ).count}"
    Specimen.find_all_by_group( Specimen::OTHER ).each do |specimen|
      Other.transaction do
        other = Other.find_or_initialize_by_name( :name => specimen.name )
        other.verified = specimen.verified
        other.description = specimen.description
        other.created_at = specimen.created_at
        other.updated_at = specimen.updated_at
        other.save
        Image.find_all_by_imageable_id_and_imageable_type( specimen.id, 'Specimen' ).each do |image|
          image.imageable_id = other.id
          image.imageable_type = 'Other'
          image.save
        end
        Occurrence.find_all_by_specimen_id_and_specimen_type( specimen.id, 'Specimen' ).each do |occurrence|
          occurrence.specimen_id = other.id
          occurrence.specimen_type = 'Other'
          occurrence.save
        end
        Comment.find_all_by_commentable_id_and_commentable_type( specimen.id, 'Specimen' ).each do |comment|
          comment.commentable_id = other.id
          comment.commentable_type = 'Other'
          comment.save
        end
        specimen.destroy
        i += 1
        say "#{specimen.name} migrated"
      end
    end
    say "Migrated: #{i}"
  end
end

class MigrateDinoflagellatesToSpecimens < ActiveRecord::Migration
  class Dinoflagellate < ActiveRecord::Base
    self.record_timestamps = false
    has_many :images, :as => :imageable
    has_many :occurrences, :as => :specimen
    has_many :comments, :as => :commentable
  end
  class Specimen < ActiveRecord::Base
    DINOFLAGELLATE = 1
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
    say "Total: #{Dinoflagellate.count}"
    Dinoflagellate.all.each do |dinoflagellate|
      Specimen.transaction do 
        specimen = Specimen.find_or_initialize_by_name_and_group( :name => dinoflagellate.name,
          :group => Specimen::DINOFLAGELLATE )
        specimen.verified = dinoflagellate.verified
        specimen.description = dinoflagellate.description
        specimen.age = dinoflagellate.age
        specimen.comparison = dinoflagellate.comparison
        specimen.range = dinoflagellate.range
        specimen.created_at = dinoflagellate.created_at
        specimen.updated_at = dinoflagellate.updated_at
        specimen.save
        Image.find_all_by_imageable_id_and_imageable_type( dinoflagellate.id, 'Dinoflagellate' ).each do |image|
          image.imageable_id = specimen.id
          image.imageable_type = 'Specimen'
          image.save
        end
        Occurrence.find_all_by_specimen_id_and_specimen_type( dinoflagellate.id, 'Dinoflagellate' ).each do |occurrence|
          occurrence.specimen_id = specimen.id
          occurrence.specimen_type = 'Specimen'
          occurrence.save
        end
        Comment.find_all_by_commentable_id_and_commentable_type( dinoflagellate.id, 'Dinoflagellate' ).each do |comment|
          comment.commentable_id = specimen.id
          comment.commentable_type = 'Specimen'
          comment.save
        end
        dinoflagellate.destroy
        i += 1
        say "#{dinoflagellate.name} migrated"
      end
    end
    say "Migrated: #{i}"
  end

  def self.down
    i = 0
    say "Total: #{Specimen.where( :group => Specimen::DINOFLAGELLATE ).count}"
    Specimen.find_all_by_group( Specimen::DINOFLAGELLATE ).each do |specimen|
      Dinoflagellate.transaction do
        dinoflagellate = Dinoflagellate.find_or_initialize_by_name( :name => specimen.name )
        dinoflagellate.verified = specimen.verified
        dinoflagellate.description = specimen.description
        dinoflagellate.age = specimen.age
        dinoflagellate.comparison = specimen.comparison
        dinoflagellate.range = specimen.range
        dinoflagellate.created_at = specimen.created_at
        dinoflagellate.updated_at = specimen.updated_at
        dinoflagellate.save
        Image.find_all_by_imageable_id_and_imageable_type( specimen.id, 'Specimen' ).each do |image|
          image.imageable_id = dinoflagellate.id
          image.imageable_type = 'Dinoflagellate'
          image.save
        end
        Occurrence.find_all_by_specimen_id_and_specimen_type( specimen.id, 'Specimen' ).each do |occurrence|
          occurrence.specimen_id = dinoflagellate.id
          occurrence.specimen_type = 'Dinoflagellate'
          occurrence.save
        end
        Comment.find_all_by_commentable_id_and_commentable_type( specimen.id, 'Specimen' ).each do |comment|
          comment.commentable_id = dinoflagellate.id
          comment.commentable_type = 'Dinoflagellate'
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

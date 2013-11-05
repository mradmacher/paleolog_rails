class AddImageableToImages < ActiveRecord::Migration
  class Image < ActiveRecord::Base
  end

  def self.up
    rename_column :images, :dinoflagellate_id, :imageable_id
    add_column :images, :imageable_type, :string
    images = Image.all
    images.each do |image|
      image.imageable_type = 'Dinoflagellate'
      image.save
    end
  end

  def self.down
    remove_column :images, :imageable_type
    rename_column :images, :imageable_id, :dinoflagellate_id
  end
end

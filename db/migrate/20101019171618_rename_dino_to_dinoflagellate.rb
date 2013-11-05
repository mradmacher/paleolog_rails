class RenameDinoToDinoflagellate < ActiveRecord::Migration
  class SampleSpecimen < ActiveRecord::Base
    set_table_name 'sample_specimens'
  end

  def self.up
    rename_table :dinos, :dinoflagellates
    rename_column :images, :dino_id, :dinoflagellate_id
    samples = SampleSpecimen.all
    samples.each do |sample|
      if sample.specimen_type == 'Dino' then
        sample.specimen_type = 'Dinoflagellate'
        sample.save
      end
    end
  end

  def self.down
    samples = SampleSpecimen.all
    samples.each do |sample|
      if sample.specimen_type == 'Dinoflagellate' then
        sample.specimen_type = 'Dino'
        sample.save
      end
    end
    rename_column :images, :dinoflagellate_id, :dino_id
    rename_table :dinoflagellates, :dinos
  end
end

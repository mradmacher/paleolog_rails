class AddCountingOccurrenceRelation < ActiveRecord::Migration
  class Sample < ActiveRecord::Base
    has_many :occurrences
    has_many :countings
  end
  class Occurrence < ActiveRecord::Base
    set_table_name 'sample_specimens'
    belongs_to :sample
    belongs_to :counting
  end
  class Counting < ActiveRecord::Base
    belongs_to :sample
    has_many :occurrences
  end
  def self.up
    add_column :sample_specimens, :counting_id, :integer
    Occurrence.reset_column_information

    Sample.all.each do |sample|
      2.times do |cnt|
        occurrences = sample.occurrences.find( :all, :conditions => { :counting => cnt+1 } )
        if not occurrences.empty?
          @counting = Counting.new( :sample_id => sample.id, :sequence => cnt+1 )
          @counting.save
        end
        occurrences.each do |occurrence|
          occurrence.update_attributes( :counting_id => @counting.id )
        end
      end
    end
    remove_column :sample_specimens, :sample_id
    remove_column :sample_specimens, :counting
  end

  def self.down
    add_column :sample_specimens, :sample_id, :integer
    add_column :sample_specimens, :counting, :integer
    Occurrence.reset_column_information

    Sample.all.each do |sample|
      sample.countings.each do |counting|
        counting.occurrences do |occurrence|
          occurrence.update_attributes( :sample_id => counting.sample_id, :counting => counting.sequence )
        end
      end
    end
    remove_column :sample_specimens, :counting_id
  end
end


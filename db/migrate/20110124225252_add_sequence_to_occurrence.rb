class AddSequenceToOccurrence < ActiveRecord::Migration
  class Counting < ActiveRecord::Base
    has_many :occurrences
  end
  class Occurrence < ActiveRecord::Base
    belongs_to :counting
  end
  def self.up
    add_column :occurrences, :sequence, :integer
    Occurrence.reset_column_information

    Counting.all.each do |counting|
      seq = 0
      counting.occurrences.each do |occurrence|
        occurrence.update_attributes( :sequence => seq )
        seq += 1
      end
    end
  end

  def self.down
    remove_column :occurrences, :sequence
  end
end

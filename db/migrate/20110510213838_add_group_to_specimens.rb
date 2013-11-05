class AddGroupToSpecimens < ActiveRecord::Migration
  class Specimen < ActiveRecord::Base
    DINOFLAGELLATE = 1
    OTHER = 2
  end
  class Group < ActiveRecord::Base
  end

  def self.up
    add_column :specimens, :group_id, :integer
    Specimen.reset_column_information
    { Specimen::DINOFLAGELLATE => 'Dinoflagellate', 
      Specimen::OTHER => 'Other' }.each_pair do |k,v|

      group = Group.find_by_name( v )
      Specimen.where( :group => k ).each do |specimen|
        specimen.group_id = group.id
        specimen.save
      end
    end
    remove_column :specimens, :group
  end

  def self.down
    add_column :specimens, :group, :integer

    Specimen.reset_column_information
    { Specimen::DINOFLAGELLATE => 'Dinoflagellate', 
      Specimen::OTHER => 'Other' }.each_pair do |k,v|

      group = Group.find_by_name( v )
      Specimen.where( :group_id => group.id ).each do |specimen|
        specimen.group = k
        specimen.save
      end
    end
    remove_column :specimens, :group_id
  end
end

class ChangeDescriptionTypeToText < ActiveRecord::Migration
  def self.up
    change_column :dinoflagellates, :description, :text, :limit => 2047
    change_column :others, :description, :text, :limit => 2047
  end

  def self.down
    change_column :dinoflagellates, :description, :string, :limit => 255
    change_column :others, :description, :string, :limit => 255
  end
end

class RenameAge < ActiveRecord::Migration
  def change
    rename_column :specimens, :age, :environmental_preferences
  end
end

class AddStatusToOccurrences < ActiveRecord::Migration
  def change
		add_column :occurrences, :status, :integer, :default => 0
  end
end

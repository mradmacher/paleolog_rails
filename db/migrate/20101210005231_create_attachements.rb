class CreateAttachements < ActiveRecord::Migration
  def self.up
    create_table :attachements do |t|
      t.string :description
      t.references :user

      t.string :attachement_file_name
      t.string :attachement_content_type
      t.integer :attachement_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :attachements
  end
end

class CreateAccountParticipations < ActiveRecord::Migration
  def change
    create_table :account_participations do |t|
      t.references :account
      t.references :user
      t.boolean :editor, :default => false

      t.timestamps
    end
  end
end

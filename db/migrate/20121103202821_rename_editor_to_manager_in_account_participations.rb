class RenameEditorToManagerInAccountParticipations < ActiveRecord::Migration
  def up
    rename_column :account_participations, :editor, :manager
  end

  def down
    rename_column :account_participations, :manager, :editor
  end
end

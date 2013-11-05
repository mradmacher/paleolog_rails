class AddUploadingDownloadingPrivileges < ActiveRecord::Migration
  class Privilege < ActiveRecord::Base
  end

  def self.up
    p = Privilege.new( :name  => 'downloading' )
    p.save
    p = Privilege.new( :name  => 'uploading' )
    p.save
  end

  def self.down
    p = Privilege.find_by_name( 'downloading' )
    p.destroy
    p = Privilege.find_by_name( 'uploading' )
    p.destroy
  end
end

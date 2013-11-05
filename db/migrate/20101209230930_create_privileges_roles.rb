class CreatePrivilegesRoles < ActiveRecord::Migration
  class Privilege < ActiveRecord::Base
    has_and_belongs_to_many :roles
  end
  class Role < ActiveRecord::Base
    has_and_belongs_to_many :privileges
  end

  def self.up
    create_table :privileges_roles, :id => false do |t|
      t.column :privilege_id, :integer
      t.column :role_id, :integer
    end
    Privilege.reset_column_information
    privs = {}
    privs[:administrating] = Privilege.find_by_name( 'administrating' ).id
    privs[:viewing] = Privilege.find_by_name( 'viewing' ).id
    privs[:editing] = Privilege.find_by_name( 'editing' ).id
    privs[:commenting] = Privilege.find_by_name( 'commenting' ).id
    Role.reset_column_information
    Role.all.each do |role|
      p_ids = []
      p_ids << privs[:administrating] if role.administration
      p_ids << privs[:viewing]
      p_ids << privs[:editing] if role.editing
      p_ids << privs[:commenting] if role.commenting

      role.privilege_ids = p_ids
      role.save
    end
    remove_column :roles, :administration
    remove_column :roles, :editing
    remove_column :roles, :commenting
  end

  def self.down
    add_column :roles, :commenting, :boolean
    add_column :roles, :editing, :boolean
    add_column :roles, :administration, :boolean
    Role.reset_column_information
    Role.all.each do |role|
      role.administration = false
      role.editing = false
      role.commenting = false
      role.privileges do |privilege|
        case privilege.name
          when 'administrating'
            role.administration = true
          when 'editing'
            role.editing = true
          when 'commenting'
            role.commenting = true
        end
      end
      role.save
    end
    drop_table :privileges_roles
  end
end

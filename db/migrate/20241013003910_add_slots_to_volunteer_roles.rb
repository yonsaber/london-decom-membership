class AddSlotsToVolunteerRoles < ActiveRecord::Migration[7.2]
  def change
    add_column :volunteer_roles, :available_slots, :integer, :default => 0
  end
end

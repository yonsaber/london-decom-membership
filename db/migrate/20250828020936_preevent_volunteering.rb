class PreeventVolunteering < ActiveRecord::Migration[7.2]
  def change
    add_column :volunteer_roles, :is_pre_event_role, :boolean, :default => 0
  end
end

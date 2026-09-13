class AddAddressToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :address, :text, null: true
  end
end

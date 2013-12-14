class RemoveExtraneousUserColumns < ActiveRecord::Migration
  def change
    remove_column :organizations, :user_id
    remove_column :repositories, :user_id
  end
end

class AddOwnerToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :owner, :string
  end
end

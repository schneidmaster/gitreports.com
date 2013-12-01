class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|

      t.belongs_to :user

      t.string :name

      t.timestamps
    end
  end
end

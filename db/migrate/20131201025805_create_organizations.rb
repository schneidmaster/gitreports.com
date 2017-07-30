class CreateOrganizations < ActiveRecord::Migration[4.2]
  def change
    create_table :organizations do |t|

      t.belongs_to :user

      t.string :name

      t.timestamps
    end
  end
end

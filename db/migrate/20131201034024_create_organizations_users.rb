class CreateOrganizationsUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :organizations_users do |t|

       t.belongs_to :organization
       t.belongs_to :user

       t.timestamps
    end
  end
end

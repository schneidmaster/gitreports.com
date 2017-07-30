class AddOrganizationToRepository < ActiveRecord::Migration[4.2]
  def change
     change_table :repositories do |t|

       t.belongs_to :organization

     end
  end
end

class AddOrganizationToRepository < ActiveRecord::Migration
  def change
     change_table :repositories do |t|

       t.belongs_to :organization

     end
  end
end

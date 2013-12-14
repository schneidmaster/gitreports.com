class CreateRepositoriesUsers < ActiveRecord::Migration
  def change
    create_table :repositories_users do |t|

      t.belongs_to :repository
      t.belongs_to :user

      t.timestamps
    end
  end
end

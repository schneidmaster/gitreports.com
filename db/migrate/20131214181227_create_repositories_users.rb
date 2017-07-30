class CreateRepositoriesUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :repositories_users do |t|

      t.belongs_to :repository
      t.belongs_to :user

      t.timestamps
    end
  end
end

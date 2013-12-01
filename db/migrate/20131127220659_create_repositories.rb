class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|

      t.belongs_to :user

      t.string :github_id
      t.string :name
      t.string :display_name
      t.string :issue_name
      t.text :prompt
      t.text :followup
      t.string :labels

      t.boolean :is_active

      t.timestamps
    end
  end
end

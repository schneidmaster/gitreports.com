class AddIssueTitleToRepositories < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :allow_issue_title, :boolean, default: false
  end
end

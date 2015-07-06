class AddIssueTitleToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :allow_issue_title, :boolean, default: false
  end
end

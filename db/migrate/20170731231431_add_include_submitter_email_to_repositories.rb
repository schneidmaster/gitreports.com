class AddIncludeSubmitterEmailToRepositories < ActiveRecord::Migration[5.1]
  def change
    add_column :repositories, :include_submitter_email, :boolean, default: false
  end
end

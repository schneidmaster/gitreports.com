class AddNotificationEmailsToRepositories < ActiveRecord::Migration[4.2]
  def change
    add_column :repositories, :notification_emails, :string
  end
end

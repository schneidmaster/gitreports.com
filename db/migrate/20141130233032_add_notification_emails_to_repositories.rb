class AddNotificationEmailsToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :notification_emails, :string
  end
end

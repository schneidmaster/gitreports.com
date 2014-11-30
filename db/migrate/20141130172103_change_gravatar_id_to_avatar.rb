class ChangeGravatarIdToAvatar < ActiveRecord::Migration
  def up
    User.where.not(gravatar_id: '').each do |user|
      user.update!(gravatar_id: "https://gravatar.com/avatar/#{user.gravatar_id}?s=96")
    end

    rename_column :users, :gravatar_id, :avatar_url
  end

  def down
    User.update_all(avatar_url: '')
    rename_column :users, :avatar_url, :gravatar_id
  end
end

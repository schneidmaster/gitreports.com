class CleanupDuplicateUsers < ActiveRecord::Migration[5.1]
  def up
    User.order(id: :asc).pluck(:id).each do |id|
      user = User.find_by(id: id)
      next if user.nil? # skip if user has already been de-duped

      dupes = User.where(username: user.username).where.not(id: id)
      next if dupes.none? # skip if there are no dupes

      # Ensure user is added to each org/repo that a dupe has,
      # then destroy the dupe.
      dupes.each do |dupe|
        dupe.repositories.each do |repo|
          repo.add_user!(user)
        end
        dupe.organizations.each do |org|
          org.add_user!(user)
        end
        dupe.destroy
      end
    end
  end

  def down; end
end

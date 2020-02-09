feature 'Repository', :needs_assets do
  let!(:organization) { create :organization }
  let!(:user) { create :user, username: 'greptest' }
  let!(:org_user) { create :user, organizations: [organization] }
  let!(:another_user) { create :user }
  let!(:repository) { create :user_repository, name: 'CoolCode', owner: user.username, users: [user] }
  let!(:org_repository) { create :repository, name: 'CoolOrg', organization: organization, users: [org_user] }
  let!(:inactive_repository) { create :repository, name: 'CoolInactive', is_active: false, users: [user] }

  describe 'edit repository' do
    context 'repository owner logged in' do
      before do
        log_in user
        visit profile_path
      end

      context 'invalid fields' do
        scenario 'shows errors' do
          click_on 'CoolCode'
          click_on 'Edit'
          fill_in 'Display name', with: 'Shrt'
          click_on 'Update'
          expect(page).to have_content('Display name must be at least 5 characters')
          fill_in 'Display name', with: 'The Coolest'
          fill_in 'Issue name', with: 'Shrt'
          click_on 'Update'
          expect(page).to have_content('Issue name must be at least 5 characters')
          fill_in 'Issue name', with: 'Big problems!'
          fill_in 'Prompt', with: 'Shrt'
          click_on 'Update'
          expect(page).to have_content('Prompt must be at least 5 characters')
          fill_in 'Prompt', with: 'Tell us what is wrong'
          fill_in 'Followup', with: 'Shrt'
          click_on 'Update'
          expect(page).to have_content('Followup must be at least 5 characters')
        end
      end

      context 'valid fields' do
        scenario 'edits the repository' do
          click_on 'CoolCode'
          click_on 'Edit'
          fill_in 'Display name', with: 'The Coolest'
          fill_in 'Issue name', with: 'Big problems!'
          fill_in 'Prompt', with: 'Tell us what is wrong'
          fill_in 'Followup', with: 'Thanks!'
          fill_in 'Labels', with: 'problem'
          fill_in 'Notification emails', with: 'valid@email.com, invalid@email, Joe Smith <joe@email.com>'
          click_on 'Update'

          expect(page).to have_content('The Coolest')
          expect(page).to have_content('Big problems!')
          expect(page).to have_content('Tell us what is wrong')
          expect(page).to have_content('Thanks!')
          expect(page).to have_content('problem')
          expect(page).to have_content('valid@email.com')
          expect(page).not_to have_content('invalid@email')
          expect(page).not_to have_content('Joe Smith')
          expect(page).to have_content('joe@email.com')
        end
      end
    end

    context 'org user logged in' do
      before do
        log_in org_user
        visit profile_path
      end

      scenario 'edits the repository' do
        click_on 'CoolOrg'
        click_on 'Edit'
        fill_in 'Display name', with: 'The Coolest'
        fill_in 'Issue name', with: 'Big problems!'
        fill_in 'Prompt', with: 'Tell us what is wrong'
        fill_in 'Followup', with: 'Thanks!'
        fill_in 'Labels', with: 'problem'
        fill_in 'Notification emails', with: 'valid@email.com, invalid@email'
        choose 'repository_allow_issue_title_yes'
        click_on 'Update'

        expect(page).to have_content('The Coolest')
        expect(page).to have_content('Big problems!')
        expect(page).to have_content('Tell us what is wrong')
        expect(page).to have_content('Thanks!')
        expect(page).to have_content('problem')
        expect(page).to have_content('valid@email.com')
        expect(page).not_to have_content('invalid@email')
        expect(page).to have_content('Yes: Users are permitted to set the issue title on GitHub.')
      end
    end

    context 'another user logged in' do
      before { log_in another_user }

      scenario 'does not permit editing' do
        visit edit_repository_path(repository)
        expect(page).not_to have_content('Update Repository')
      end
    end

    context 'nobody logged in' do
      scenario 'does not permit editing' do
        visit edit_repository_path(repository)
        expect(page).not_to have_content('Update Repository')
      end
    end
  end

  describe 'activates and deactivates repository' do
    context 'repository owner logged in' do
      before do
        log_in user
        visit profile_path
      end

      scenario 'deactivates and reactivates the repository' do
        click_on 'CoolCode'
        expect(page).to have_content('Status: Active')
        click_on 'Deactivate'
        expect(page).to have_content('Status: Inactive')
        click_on 'Activate'
        expect(page).to have_content('Status: Active')
      end
    end

    context 'org user logged in' do
      before do
        log_in org_user
        visit profile_path
      end

      scenario 'edits the repository' do
        click_on 'CoolOrg'
        expect(page).to have_content('Status: Active')
        click_on 'Deactivate'
        expect(page).to have_content('Status: Inactive')
        click_on 'Activate'
        expect(page).to have_content('Status: Active')
      end
    end
  end
end

require 'spec_helper'

feature 'Repository' do
  let!(:organization) { create :organization }
  let!(:user) { create :user, username: 'greptest' }
  let!(:org_user) { create :user, organizations: [organization] }
  let!(:another_user) { create :user }
  let!(:repository) { create :user_repository, name: 'CoolCode', owner: user.username, users: [user] }
  let!(:org_repository) { create :repository, name: 'CoolOrg', organization: organization, users: [org_user] }
  let!(:inactive_repository) { create :repository, name: 'CoolInactive', is_active: false, users: [user] }

  describe 'show repository' do
    context 'holder does not exist' do
      scenario 'shows 404' do
        visit repository_public_path('joe_schmoe', inactive_repository.name)
        expect(page).to have_content(I18n.t('repositories.not_found.message'))
      end
    end

    context 'repository is activated' do
      scenario 'shows the repository issue page' do
        visit repository_public_path(user.username, repository.name)
        expect(page).to have_content(repository.name)
      end
    end

    context 'repository is not activated' do
      scenario 'shows 404' do
        visit repository_public_path(user.username, inactive_repository.name)
        expect(page).to have_content(I18n.t('repositories.not_found.message'))
      end
    end

    context 'URL params are passed' do
      scenario 'prefills the issue form' do
        visit repository_public_path(user.username, repository.name, name: 'Important Issue', email: 'some@email.com', details: 'Big details')
        expect(find_field('name').value).to eq('Important Issue')
        expect(find_field('email').value).to eq('some@email.com')
        expect(find_field('details').value).to eq('Big details')
      end
    end

    context 'locale is passed in headers' do
      before { Capybara.current_session.driver.header('Accept-Language', 'pl') }
      after { Capybara.current_session.driver.header('Accept-Language', 'pl') }

      scenario 'uses requested language' do
        visit repository_public_path(user.username, repository.name)
        expect(page).to have_content('Zgłoszenie')
      end
    end
  end

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

  describe 'submit issue' do
    context 'custom display name, prompt, and followup are set' do
      before { override_captcha true }

      let!(:repository) { create :user_repository, owner: user.username, users: [user], display_name: 'Cool Code', prompt: 'Enter your bug please', followup: 'Thanks a lot!' }

      scenario 'shows custom display name, prompt, and followup' do
        visit repository_public_path(repository.holder_name, repository.name)
        expect(page).to have_content('Cool Code')
        expect(page).not_to have_content(repository.name)
        expect(page).to have_content('Enter your bug please')
        expect(page).not_to have_content('Please enter your bug report or feature request')
        fill_in 'name', with: 'Joe Schmoe'
        fill_in 'email', with: 'joe.schmoe@gmail.com'
        fill_in 'details', with: 'Your code is broken!'
        fill_in 'captcha', with: 'asdfgh'
        click_on I18n.t('submit_form.label.submit')
        expect(page).to have_content('Thanks a lot!')
        expect(page).not_to have_content('Thanks for submitting your report!')
      end
    end

    context 'no custom display, prompt, followup' do
      scenario 'shows default display name and prompt' do
        visit repository_public_path(repository.holder_name, repository.name)
        expect(page).to have_content(repository.name)
        expect(page).to have_content('Please enter your bug report or feature request')
      end
    end

    context 'captcha is correct' do
      before { override_captcha true }

      scenario 'submits issue' do
        visit repository_public_path(repository.holder_name, repository.name)
        fill_in 'name', with: 'Joe Schmoe'
        fill_in 'email', with: 'joe.schmoe@gmail.com'
        fill_in 'details', with: 'Your code is broken!'
        fill_in 'captcha', with: 'asdfgh'
        click_on I18n.t('submit_form.label.submit')
        expect(page).to have_content('Thanks for submitting your report!')

        # Should have queued issue submission
        expect(GithubWorker.jobs.size).to eq(1)
      end
    end

    context 'captcha is incorrect' do
      before { override_captcha false }

      scenario 'prefills issue page and shows error' do
        visit repository_public_path(repository.holder_name, repository.name)
        fill_in 'name', with: 'Joe Schmoe'
        fill_in 'email', with: 'joe.schmoe@gmail.com'
        fill_in 'details', with: 'Your code is broken!'
        fill_in 'captcha', with: 'asdfgh'
        click_on I18n.t('submit_form.label.submit')
        expect(page).to have_content('Incorrect CAPTCHA; please retry!')
        expect(find_field('name').value).to eq('Joe Schmoe')
        expect(find_field('email').value).to eq('joe.schmoe@gmail.com')
        expect(find_field('details').value).to eq('Your code is broken!')
      end
    end
  end
end

feature 'Issue', :needs_assets do
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
        expect(enqueued_jobs.size).to eq(1)
        expect(enqueued_jobs.first[:args]).to eq(['submit_issue', 1, 'Joe Schmoe', 'joe.schmoe@gmail.com', true, nil, 'Your code is broken!'])
      end

      scenario 'submits issue without public email' do
        visit repository_public_path(repository.holder_name, repository.name)
        fill_in 'name', with: 'Joe Schmoe'
        fill_in 'email', with: 'joe.schmoe@gmail.com'
        uncheck I18n.t('submit_form.label.email_public')
        fill_in 'details', with: 'Your code is broken!'
        fill_in 'captcha', with: 'asdfgh'
        click_on I18n.t('submit_form.label.submit')
        expect(page).to have_content('Thanks for submitting your report!')

        # Should have queued issue submission
        expect(enqueued_jobs.size).to eq(1)
        expect(enqueued_jobs.first[:args]).to eq(['submit_issue', 1, 'Joe Schmoe', 'joe.schmoe@gmail.com', false, nil, 'Your code is broken!'])
      end
    end

    context 'captcha is incorrect' do
      before { override_captcha false }

      scenario 'prefills issue page and shows error' do
        visit repository_public_path(repository.holder_name, repository.name)
        fill_in 'name', with: 'Joe Schmoe'
        fill_in 'email', with: 'joe.schmoe@gmail.com'
        uncheck I18n.t('submit_form.label.email_public')
        fill_in 'details', with: 'Your code is broken!'
        fill_in 'captcha', with: 'asdfgh'
        click_on I18n.t('submit_form.label.submit')
        expect(page).to have_content('Incorrect CAPTCHA; please retry!')
        expect(find_field('name').value).to eq('Joe Schmoe')
        expect(find_field('email').value).to eq('joe.schmoe@gmail.com')
        expect(find_field(I18n.t('submit_form.label.email_public'))).to_not be_checked
        expect(find_field('details').value).to eq('Your code is broken!')
      end
    end
  end
end

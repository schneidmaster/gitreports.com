require 'spec_helper'

feature 'Authentication' do
  describe 'login and get repositories from API' do
    let!(:state) { SecureRandom.hex }

    before do
      page.set_rack_session(state: state)
    end

    context 'state is incorrect' do
      scenario 'does not log in' do
        visit "/github_callback?state=wrongstate&code=#{SecureRandom.hex}"
        expect(page).to have_content('An error occurred; please try again')
      end
    end

    context 'rate limit is expired' do
      scenario 'shows rate limited page' do
        visit "/github_callback?state=#{state}&code=rate_limit_expired"
        expect(page).to have_content('Git Reports is currently experiencing heavy traffic.')
      end
    end

    context 'access token request fails' do
      scenario 'shows error message' do
        visit "/github_callback?state=#{state}&code=access_fail"
        expect(page).to have_content('An error occurred; please try again')
      end
    end

    context 'first user login' do
      scenario 'logs in the user' do
        visit "/github_callback?state=#{state}&code=#{SecureRandom.hex}"
        expect(page).to have_content('Logged in!')

        # Should have queued repository update
        expect(GithubWorker.jobs.size).to eq(1)
      end
    end
  end

  describe 'logout' do
    let!(:user) { create :user, name: 'Joe Schmoe' }

    context 'user is logged in' do
      before { log_in user }

      scenario 'logs out the user' do
        visit logout_path
        expect(page).to have_content('Login')
        expect(page).not_to have_content('Joe Schmoe')
      end
    end
  end
end

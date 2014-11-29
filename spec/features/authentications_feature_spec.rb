require 'spec_helper'

feature 'Authentication' do
  describe 'login and get repositories from API' do
    let!(:state) { SecureRandom.hex }
    let!(:user) { create :user }

    before do
      page.set_rack_session(state: state)
    end

    scenario 'retrieves and stores repositories' do
      visit "/github_callback?state=#{state}&code=#{SecureRandom.hex}"
      expect(page).to have_content('Logged in!')
      expect(page).to have_content('CoolCode')
      expect(page).to have_content('PrettyProject')
      expect(page).to have_content('NeatOrgCode')
      expect(page).to have_content('NeatOrgProject')
    end
  end
end
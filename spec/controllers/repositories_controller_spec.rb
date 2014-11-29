require 'spec_helper'

describe RepositoriesController do
  let!(:organization) { create :organization }
  let!(:user) { create :user }
  let!(:org_user) { create :user, organizations: [organization] }
  let!(:another_user) { create :user }

  describe '#repository_show' do
    let!(:repository) { create :user_repository, users: [user] }
    let!(:org_repository) { create :repository, organization: organization, users: [org_user] }

    context 'repository owner logged in' do
      before { log_in user }
      subject  { get :repository_show, id: repository }

      it 'shows the repository' do
        expect(subject).to render_template(:repository_show)
      end
    end

    context 'org user logged in' do
      before { log_in org_user }
      subject  { get :repository_show, id: org_repository }

      it 'shows the repository' do
        expect(subject).to render_template(:repository_show)
      end
    end

    context 'another user logged in' do
      before { log_in another_user }
      subject  { get :repository_show, id: repository }

      it 'does not show the repository' do
        expect(subject).to redirect_to(profile_path)
      end
    end

    context 'repo does not exist' do
      before { log_in another_user }
      subject  { get :repository_show, id: 0 }

      it 'renders 404' do
        expect(subject).to render_template('404')
      end
    end
  end

  describe '#repository_edit' do
    let!(:repository) { create :user_repository, users: [user] }
    let!(:org_repository) { create :repository, organization: organization, users: [org_user] }

    context 'repository owner logged in' do
      before { log_in user }
      subject  { get :repository_edit, id: repository }

      it 'shows the repository' do
        expect(subject).to render_template(:repository_edit)
      end
    end

    context 'org user logged in' do
      before { log_in org_user }
      subject  { get :repository_edit, id: org_repository }

      it 'shows the repository' do
        expect(subject).to render_template(:repository_edit)
      end
    end

    context 'another user logged in' do
      before { log_in another_user }
      subject  { get :repository_edit, id: repository }

      it 'does not show the repository' do
        expect(subject).to redirect_to(profile_path)
      end
    end

    context 'repo does not exist' do
      before { log_in another_user }
      subject  { get :repository_edit, id: 0 }

      it 'renders 404' do
        expect(subject).to render_template('404')
      end
    end
  end

  describe '#repository_activate' do
    let!(:repository) { create :user_repository, is_active: false, users: [user] }
    let!(:org_repository) { create :repository, is_active: false, organization: organization, users: [org_user] }

    context 'repository owner logged in' do
      before { log_in user }
      subject  { post :repository_activate, id: repository }

      it 'activates the repository' do
        expect(subject).to redirect_to(repository_path(repository))
      end
    end

    context 'org user logged in' do
      before { log_in org_user }
      subject  { post :repository_activate, id: org_repository }

      it 'activates the repository' do
        expect(subject).to redirect_to(repository_path(org_repository))
      end
    end

    context 'another user logged in' do
      before { log_in another_user }
      subject  { post :repository_activate, id: repository }

      it 'does not allow activation' do
        expect(subject).to redirect_to(profile_path)
      end
    end

    context 'repo does not exist' do
      before { log_in another_user }
      subject  { post :repository_activate, id: 0 }

      it 'renders 404' do
        expect(subject).to render_template('404')
      end
    end
  end

  describe '#repository_deactivate' do
    let!(:repository) { create :user_repository, users: [user] }
    let!(:org_repository) { create :repository, organization: organization, users: [org_user] }

    context 'repository owner logged in' do
      before { log_in user }
      subject  { post :repository_deactivate, id: repository }

      it 'deactivates the repository' do
        expect(subject).to redirect_to(repository_path(repository))
      end
    end

    context 'org user logged in' do
      before { log_in org_user }
      subject  { post :repository_deactivate, id: org_repository }

      it 'deactivates the repository' do
        expect(subject).to redirect_to(repository_path(org_repository))
      end
    end

    context 'another user logged in' do
      before { log_in another_user }
      subject  { post :repository_deactivate, id: repository }

      it 'dedoes not allow activation' do
        expect(subject).to redirect_to(profile_path)
      end
    end

    context 'repo does not exist' do
      before { log_in another_user }
      subject  { post :repository_deactivate, id: 0 }

      it 'renders 404' do
        expect(subject).to render_template('404')
      end
    end
  end
end

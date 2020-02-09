describe RepositoriesController do
  let!(:organization) { create :organization }
  let!(:user) { create :user }
  let!(:org_user) { create :user, organizations: [organization] }
  let!(:another_user) { create :user }

  describe '#load_status' do
    subject { get :load_status }

    context 'job ID does not exist' do
      it 'returns false' do
        expect(subject.body).to eq('false')
      end
    end

    context 'job ID is set' do
      before { session[:job_id] = 1 }
      it 'checks job status' do
        expect(subject.body).to eq('false')
      end
    end
  end

  describe '#show' do
    let!(:repository) { create :user_repository, users: [user] }
    let!(:org_repository) { create :repository, organization: organization, users: [org_user] }

    context 'repository owner logged in' do
      before { log_in user }
      subject { get :show, params: { id: repository } }

      it 'shows the repository' do
        expect(subject).to render_template(:show)
      end
    end

    context 'org user logged in' do
      before { log_in org_user }
      subject { get :show, params: { id: org_repository } }

      it 'shows the repository' do
        expect(subject).to render_template(:show)
      end
    end

    context 'another user logged in' do
      before { log_in another_user }
      subject { get :show, params: { id: repository } }

      it 'does not show the repository' do
        expect(subject).to redirect_to(profile_path)
      end
    end

    context 'repo does not exist' do
      before { log_in another_user }
      subject { get :show, params: { id: 0 } }

      it 'renders 404' do
        expect(subject).to render_template('not_found')
      end
    end
  end

  describe '#edit' do
    let!(:repository) { create :user_repository, users: [user] }
    let!(:org_repository) { create :repository, organization: organization, users: [org_user] }

    context 'repository owner logged in' do
      before { log_in user }
      subject { get :edit, params: { id: repository } }

      it 'shows the repository' do
        expect(subject).to render_template(:edit)
      end
    end

    context 'org user logged in' do
      before { log_in org_user }
      subject { get :edit, params: { id: org_repository } }

      it 'shows the repository' do
        expect(subject).to render_template(:edit)
      end
    end

    context 'another user logged in' do
      before { log_in another_user }
      subject { get :edit, params: { id: repository } }

      it 'does not show the repository' do
        expect(subject).to redirect_to(profile_path)
      end
    end

    context 'repo does not exist' do
      before { log_in another_user }
      subject { get :edit, params: { id: 0 } }

      it 'renders 404' do
        expect(subject).to render_template('not_found')
      end
    end
  end

  describe '#update' do
    let!(:repository) { create :user_repository, is_active: false, users: [user] }
    let!(:org_repository) { create :repository, is_active: false, organization: organization, users: [org_user] }

    context 'repository owner logged in' do
      before { log_in user }
      subject { patch :update, params: { id: repository, repository: { is_active: true } } }

      it 'activates the repository' do
        expect(subject).to redirect_to(repository_path(repository))
      end
    end

    context 'org user logged in' do
      before { log_in org_user }
      subject { patch :update, params: { id: org_repository, repository: { is_active: true } } }

      it 'activates the repository' do
        expect(subject).to redirect_to(repository_path(org_repository))
      end
    end

    context 'another user logged in' do
      before { log_in another_user }
      subject { patch :update, params: { id: repository, repository: { is_active: true } } }

      it 'does not allow activation' do
        expect(subject).to redirect_to(profile_path)
      end
    end

    context 'repo does not exist' do
      before { log_in another_user }
      subject { patch :update, params: { id: 0, repository: { is_active: true } } }

      it 'renders 404' do
        expect(subject).to render_template('not_found')
      end
    end
  end
end

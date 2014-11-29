require 'spec_helper'

describe AuthenticationsController do
  describe '#login' do
    let!(:user) { create :user }

    subject { get :login }

    context 'user is not logged in' do
      it 'redirects to login url' do
        expect(subject).to redirect_to(%r{\Ahttps://github.com/login/oauth/authorize})
      end
    end

    context 'user is already logged in' do
      before { log_in(user) }
      it 'redirects home' do
        expect(subject).to redirect_to(root_path)
      end
    end
  end
end

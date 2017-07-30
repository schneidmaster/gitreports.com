describe ErrorsController do
  describe '#error_404' do
    subject { get :error_404 }

    it 'returns 404 response' do
      expect(subject).to have_http_status(:not_found)
      expect(subject).to render_template(:error_404)
    end
  end

  describe '#error_422' do
    subject { get :error_422 }

    it 'returns 422 response' do
      expect(subject).to have_http_status(:unprocessable_entity)
      expect(subject).to render_template(:error_422)
    end
  end

  describe '#error_500' do
    subject { get :error_500 }

    it 'returns 500 response' do
      expect(subject).to have_http_status(:internal_server_error)
      expect(subject).to render_template(:error_500)
    end
  end
end

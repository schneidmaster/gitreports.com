describe GithubJob do
  subject { GithubJob.new.perform(method, *args) }

  let(:method) { 'load_repositories' }
  let(:args) { ['123'] }

  it 'calls provided method with provided args' do
    expect(GithubService).to receive('load_repositories').with('123')
    subject
  end
end

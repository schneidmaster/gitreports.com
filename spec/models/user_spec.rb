require 'spec_helper'

describe Repository do
  describe '#avatar_url' do
    context 'avatar url is blank' do
      subject { create :user, username: 'joeschmoe', avatar_url: nil }

      it 'returns identicon url' do
        expect(subject.avatar_url).to eq('https://github.com/identicons/joeschmoe.png')
      end
    end

    context 'avatar url is populated' do
      subject { create :user, username: 'joeschmoe', avatar_url: 'https://github.com/some_other_url/joeschmoe.png' }

      it 'returns avatar url' do
        expect(subject.avatar_url).to eq('https://github.com/some_other_url/joeschmoe.png')
      end
    end
  end
end

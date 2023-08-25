# frozen_string_literal: true

RSpec.shared_examples 'search results filtered by archived' do |feature_flag_name|
  context 'when filter not provided (all behavior)' do
    let(:filters) { {} }

    it 'returns unarchived results only' do
      expect(results.objects(scope)).to include unarchived_result
      expect(results.objects(scope)).not_to include archived_result
    end
  end

  context 'when include_archived is true' do
    let(:filters) { { include_archived: true } }

    it 'returns archived and unarchived results' do
      expect(results.objects(scope)).to include unarchived_result
      expect(results.objects(scope)).to include archived_result
    end
  end

  context 'when include_archived filter is false' do
    let(:filters) { { include_archived: false } }

    it 'returns unarchived results only' do
      expect(results.objects(scope)).to include unarchived_result
      expect(results.objects(scope)).not_to include archived_result
    end
  end

  context "when the #{feature_flag_name} feature flag is disabled" do
    let(:filters) { {} }

    before do
      stub_feature_flags("#{feature_flag_name}": false)
    end

    it 'returns archived and unarchived results' do
      expect(results.objects(scope)).to include unarchived_result
      expect(results.objects(scope)).to include archived_result
    end
  end
end

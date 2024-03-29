# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'PipelineTriggerCreate', feature_category: :continuous_integration do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:project) { create(:project) }

  let(:mutation) { graphql_mutation(:pipeline_trigger_create, params) }
  let(:project_path) { project.full_path }
  let(:description) { 'Ye old pipeline trigger token' }

  let(:params) do
    {
      project_path: project_path,
      description: description
    }
  end

  subject { post_graphql_mutation(mutation, current_user: user) }

  context 'when unauthorized' do
    it 'returns an error' do
      subject

      expect(graphql_errors).not_to be_empty
      expect(graphql_errors[0]['message'])
        .to eq(
          "The resource that you are attempting to access does not exist " \
          "or you don't have permission to perform this action"
        )
    end
  end

  context 'when authorized' do
    before_all do
      project.add_owner(user)
    end

    context 'when the params are invalid' do
      let(:description) { nil }

      it 'does not create a pipeline trigger token and returns an error' do
        expect { subject }.not_to change { project.triggers.count }
        expect(response).to have_gitlab_http_status(:success)
        expect(graphql_errors.to_s).to include('provided invalid value for description (Expected value to not be null)')
      end
    end

    context 'when the params are valid' do
      it 'creates a pipeline trigger token' do
        expect { subject }.to change { project.triggers.count }.by(1)
        expect(graphql_errors.to_s).to eql("")
      end

      it 'returns the new pipeline trigger token' do
        subject

        expect(graphql_data_at(:pipeline_trigger_create, :pipeline_trigger)).to match a_hash_including(
          'owner' => a_hash_including(
            'id' => user.to_global_id.to_s,
            'username' => user.username,
            'name' => user.name
          ),
          'description' => description,
          "canAccessProject" => true,
          "hasTokenExposed" => true,
          "lastUsed" => nil
        )
      end
    end
  end
end

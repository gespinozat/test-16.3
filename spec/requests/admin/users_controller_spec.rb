# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::UsersController, :enable_admin_mode, feature_category: :user_management do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:user) { create(:user) }

  before do
    sign_in(admin)
  end

  describe 'PUT #block' do
    context 'when request format is :json' do
      subject(:request) { put block_admin_user_path(user, format: :json) }

      context 'when user was blocked' do
        it 'returns 200 and json data with notice' do
          request

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to include('notice' => 'Successfully blocked')
        end
      end

      context 'when user was not blocked' do
        before do
          allow_next_instance_of(::Users::BlockService) do |service|
            allow(service).to receive(:execute).and_return({ status: :failed })
          end
        end

        it 'returns 200 and json data with error' do
          request

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to include('error' => 'Error occurred. User was not blocked')
        end
      end
    end
  end

  describe 'PUT #unlock' do
    before do
      user.lock_access!
    end

    subject(:request) { put unlock_admin_user_path(user) }

    it 'unlocks the user' do
      expect { request }.to change { user.reload.access_locked? }.from(true).to(false)
    end
  end
end

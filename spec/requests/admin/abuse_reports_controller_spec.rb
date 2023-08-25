# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::AbuseReportsController, type: :request, feature_category: :insider_threat do
  include AdminModeHelper

  let_it_be(:admin) { create(:admin) }

  before do
    enable_admin_mode!(admin)
    sign_in(admin)
  end

  describe 'GET #index' do
    let!(:open_report) { create(:abuse_report) }
    let!(:closed_report) { create(:abuse_report, :closed) }

    it 'returns open reports by default' do
      get admin_abuse_reports_path

      expect(assigns(:abuse_reports).count).to eq 1
      expect(assigns(:abuse_reports).first.open?).to eq true
    end

    it 'returns reports by specified status' do
      get admin_abuse_reports_path, params: { status: 'closed' }

      expect(assigns(:abuse_reports).count).to eq 1
      expect(assigns(:abuse_reports).first.closed?).to eq true
    end

    context 'when abuse_reports_list flag is disabled' do
      before do
        stub_feature_flags(abuse_reports_list: false)
      end

      it 'returns all reports by default' do
        get admin_abuse_reports_path

        expect(assigns(:abuse_reports).count).to eq 2
      end
    end
  end

  describe 'GET #show' do
    let!(:report) { create(:abuse_report) }

    it 'returns the requested report' do
      get admin_abuse_report_path(report)

      expect(assigns(:abuse_report)).to eq report
    end
  end

  shared_examples 'moderates user' do
    let(:report) { create(:abuse_report) }
    let(:params) { { user_action: 'block_user', close: 'true', reason: 'spam', comment: 'obvious spam' } }
    let(:expected_params) { ActionController::Parameters.new(params).permit! }
    let(:message) { 'Service response' }

    subject(:request) { put path }

    it 'invokes the Admin::AbuseReports::ModerateUserService' do
      expect_next_instance_of(Admin::AbuseReports::ModerateUserService, report, admin, expected_params) do |service|
        expect(service).to receive(:execute).and_call_original
      end

      request
    end

    context 'when the service response is a success' do
      before do
        allow_next_instance_of(Admin::AbuseReports::ModerateUserService, report, admin, expected_params) do |service|
          allow(service).to receive(:execute).and_return(ServiceResponse.success(message: message))
        end

        request
      end

      it 'returns the service response message with a success status' do
        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['message']).to eq(message)
      end
    end

    context 'when the service response is an error' do
      before do
        allow_next_instance_of(Admin::AbuseReports::ModerateUserService, report, admin, expected_params) do |service|
          allow(service).to receive(:execute).and_return(ServiceResponse.error(message: message))
        end

        request
      end

      it 'returns the service response message with a failed status' do
        expect(response).to have_gitlab_http_status(:unprocessable_entity)
        expect(json_response['message']).to eq(message)
      end
    end
  end

  describe 'PUT #update' do
    let(:path) { admin_abuse_report_path(report, params) }

    it_behaves_like 'moderates user'
  end

  describe 'PUT #moderate_user' do
    let(:path) { moderate_user_admin_abuse_report_path(report, params) }

    it_behaves_like 'moderates user'
  end

  describe 'DELETE #destroy' do
    let!(:report) { create(:abuse_report) }
    let(:params) { {} }

    subject { delete admin_abuse_report_path(report, params) }

    it 'destroys the report' do
      expect { subject }.to change { AbuseReport.count }.by(-1)
    end

    context 'when passing the `remove_user` parameter' do
      let(:params) { { remove_user: true } }

      it 'calls the `remove_user` method' do
        expect_next_found_instance_of(AbuseReport) do |report|
          expect(report).to receive(:remove_user).with(deleted_by: admin)
        end

        subject
      end
    end
  end
end

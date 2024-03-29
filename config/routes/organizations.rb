# frozen_string_literal: true

resources :organizations, only: [:show], param: :organization_path, controller: 'organizations/organizations' do
  member do
    get :groups_and_projects
  end
end

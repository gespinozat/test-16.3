# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Multi-file editor new directory', :js, feature_category: :web_ide do
  include Features::WebIdeSpecHelpers

  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }

  before do
    stub_feature_flags(vscode_web_ide: false)

    project.add_maintainer(user)
    sign_in(user)

    visit project_tree_path(project, :master)

    wait_for_requests

    ide_visit_from_link
  end

  after do
    set_cookie('new_repo', 'false')
  end

  it 'creates directory in current directory' do
    wait_for_all_requests

    all('.ide-tree-actions button').last.click

    page.within('.modal') do
      find('.form-control').set('folder name')

      click_button('Create directory')
    end

    expect(page).to have_content('folder name')

    first('.ide-tree-actions button').click

    page.within('.modal') do
      find('.form-control').set('folder name/file name')

      click_button('Create file')
    end

    wait_for_requests

    find('.js-ide-commit-mode').click

    # Compact mode depends on the size of window. If it is shorter than MAX_WINDOW_HEIGHT_COMPACT,
    # (as it is with WEBDRIVER_HEADLESS=0), this initial commit button will exist. Otherwise, if it is
    # taller (as it is by default with chrome headless) then the button will not exist.
    if page.has_css?('[data-testid="begin-commit-button"]')
      find('[data-testid="begin-commit-button"]').click
    end

    fill_in('commit-message', with: 'commit message ide')

    find(:css, ".js-ide-commit-new-mr input").set(false)

    wait_for_requests

    page.within '.multi-file-commit-form' do
      click_button('Commit')

      wait_for_requests
    end

    find('.js-ide-edit-mode').click

    expect(page).to have_content('folder name')
  end
end

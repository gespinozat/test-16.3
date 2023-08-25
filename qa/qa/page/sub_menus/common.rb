# frozen_string_literal: true

module QA
  module Page
    module SubMenus
      module Common
        prepend Mobile::Page::SubMenus::Common if QA::Runtime::Env.mobile_layout?

        def self.included(base)
          super

          base.class_eval do
            view 'app/assets/javascripts/super_sidebar/components/super_sidebar.vue' do
              element :navbar
            end
          end
        end

        def hover_element(element)
          within_sidebar do
            find_element(element).hover
            yield
          end
        end

        def within_sidebar(&block)
          wait_for_requests

          within_element(:navbar, &block)
        end

        def within_submenu(element = nil, &block)
          if element
            within_element(element, &block)
          else
            within_submenu_without_element(&block)
          end
        end

        private

        # Opens the new item menu and yields to the block
        #
        # @return [void]
        def within_new_item_menu
          click_element('new-menu-toggle')

          yield
        end

        # Implementation for super-sidebar, will replace within_submenu
        #
        # @param [String] parent_menu_name
        # @param [String] parent_section_id
        # @param [String] sub_menu
        # @return [void]
        def open_submenu(parent_menu_name, sub_menu)
          # prevent closing sub-menu if it was already open
          unless has_element?(:menu_section, section_name: parent_menu_name, wait: 0)
            click_element(:menu_section_button, section_name: parent_menu_name)
          end

          within_element(:menu_section, section_name: parent_menu_name) do
            click_element(:nav_item_link, submenu_item: sub_menu)
          end
        end

        def within_submenu_without_element(&block)
          has_css?('.fly-out-list') ? within('.fly-out-list', &block) : yield
        end
      end
    end
  end
end

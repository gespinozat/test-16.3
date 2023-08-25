import { GlButton, GlDropdown, GlLoadingIcon, GlToggle, GlAlert } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { helpPagePath } from '~/helpers/help_page_helper';
import ServiceDeskSetting from '~/projects/settings_service_desk/components/service_desk_setting.vue';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

describe('ServiceDeskSetting', () => {
  let wrapper;

  const findButton = () => wrapper.findComponent(GlButton);
  const findClipboardButton = () => wrapper.findComponent(ClipboardButton);
  const findIncomingEmail = () => wrapper.findByTestId('incoming-email');
  const findIncomingEmailLabel = () => wrapper.findByTestId('incoming-email-label');
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findTemplateDropdown = () => wrapper.findComponent(GlDropdown);
  const findToggle = () => wrapper.findComponent(GlToggle);
  const findSuffixFormGroup = () => wrapper.findByTestId('suffix-form-group');
  const findIssueTrackerInfo = () => wrapper.findComponent(GlAlert);
  const findIssueHelpLink = () => wrapper.findByTestId('issue-help-page');

  const createComponent = ({ props = {} } = {}) =>
    extendedWrapper(
      mount(ServiceDeskSetting, {
        propsData: {
          isEnabled: true,
          isIssueTrackerEnabled: true,
          ...props,
        },
      }),
    );

  describe('with issue tracker', () => {
    it('does not show the info notice when enabled', () => {
      wrapper = createComponent();

      expect(findIssueTrackerInfo().exists()).toBe(false);
    });

    it('shows info notice when disabled with help page link', () => {
      wrapper = createComponent({
        props: {
          isIssueTrackerEnabled: false,
        },
      });

      expect(findIssueTrackerInfo().exists()).toBe(true);
      expect(findIssueHelpLink().text()).toEqual('activate the issue tracker');
      expect(findIssueHelpLink().attributes('href')).toBe(
        helpPagePath('user/project/settings/index.md', {
          anchor: 'configure-project-visibility-features-and-permissions',
        }),
      );
    });
  });

  describe('when isEnabled=true', () => {
    describe('only isEnabled', () => {
      describe('as project admin', () => {
        beforeEach(() => {
          wrapper = createComponent();
        });

        it('should see activation checkbox', () => {
          expect(findToggle().props('label')).toBe(ServiceDeskSetting.i18n.toggleLabel);
        });

        it('should see main panel with the email info', () => {
          expect(findIncomingEmailLabel().exists()).toBe(true);
        });

        it('should see loading spinner and not the incoming email', () => {
          expect(findLoadingIcon().exists()).toBe(true);
          expect(findIncomingEmail().exists()).toBe(false);
        });

        it('should display help text', () => {
          expect(findSuffixFormGroup().text()).toContain(
            'To add a custom suffix, set up a Service Desk email address',
          );
          expect(findSuffixFormGroup().text()).not.toContain(
            'Add a suffix to Service Desk email address',
          );
        });
      });
    });

    describe('service desk email "from" name', () => {
      it('service desk e-mail "from" name input appears', () => {
        wrapper = createComponent();

        const input = wrapper.findByTestId('email-from-name');

        expect(input.exists()).toBe(true);
        expect(input.attributes('disabled')).toBeUndefined();
      });
    });

    describe('service desk toggle', () => {
      it('emits an event to turn on Service Desk when clicked', async () => {
        wrapper = createComponent();

        findToggle().vm.$emit('change', true);

        await nextTick();

        expect(wrapper.emitted('toggle')[0]).toEqual([true]);
      });
    });

    describe('with incomingEmail', () => {
      const incomingEmail = 'foo@bar.com';

      beforeEach(() => {
        wrapper = createComponent({
          props: { incomingEmail },
        });
      });

      it('should see email and not the loading spinner', () => {
        expect(findIncomingEmail().element.value).toEqual(incomingEmail);
        expect(findLoadingIcon().exists()).toBe(false);
      });

      it('renders a copy to clipboard button', () => {
        expect(findClipboardButton().exists()).toBe(true);
        expect(findClipboardButton().props()).toEqual(
          expect.objectContaining({
            title: 'Copy',
            text: incomingEmail,
          }),
        );
      });
    });

    describe('with serviceDeskEmail', () => {
      describe('serviceDeskEmail is different than incomingEmail', () => {
        const incomingEmail = 'foo@bar.com';
        const serviceDeskEmail = 'servicedesk@bar.com';

        beforeEach(() => {
          wrapper = createComponent({
            props: { incomingEmail, serviceDeskEmail },
          });
        });

        it('should see service desk email', () => {
          expect(findIncomingEmail().element.value).toEqual(serviceDeskEmail);
        });
      });

      describe('project suffix', () => {
        it('input is hidden', () => {
          wrapper = createComponent({
            props: { serviceDeskEmailEnabled: false },
          });

          const input = wrapper.findByTestId('project-suffix');

          expect(input.exists()).toBe(false);
        });

        it('input is enabled', () => {
          wrapper = createComponent({
            props: { serviceDeskEmailEnabled: true },
          });

          const input = wrapper.findByTestId('project-suffix');

          expect(input.exists()).toBe(true);
          expect(input.attributes('disabled')).toBeUndefined();
        });

        it('shows error when value contains uppercase or special chars', async () => {
          wrapper = createComponent({
            props: { email: 'foo@bar.com', serviceDeskEmailEnabled: true },
          });

          const input = wrapper.findByTestId('project-suffix');

          input.setValue('abc_A.');
          input.trigger('blur');

          await nextTick();

          const errorText = wrapper.find('.invalid-feedback');
          expect(errorText.exists()).toBe(true);
        });
      });

      describe('serviceDeskEmail is the same as incomingEmail', () => {
        const email = 'foo@bar.com';

        beforeEach(() => {
          wrapper = createComponent({
            props: { incomingEmail: email, serviceDeskEmail: email },
          });
        });

        it('should see service desk email', () => {
          expect(findIncomingEmail().element.value).toEqual(email);
        });
      });
    });
  });

  describe('save button', () => {
    it('renders a save button to save a template', () => {
      wrapper = createComponent();
      const saveButton = findButton();

      expect(saveButton.text()).toContain('Save changes');
      expect(saveButton.props()).toMatchObject({
        variant: 'confirm',
      });
    });

    it('emits a save event with the chosen template when the save button is clicked', async () => {
      wrapper = createComponent({
        props: {
          initialSelectedTemplate: 'Bug',
          initialSelectedFileTemplateProjectId: 42,
          initialOutgoingName: 'GitLab Support Bot',
          initialProjectKey: 'key',
        },
      });

      findButton().vm.$emit('click');

      await nextTick();

      const payload = {
        selectedTemplate: 'Bug',
        fileTemplateProjectId: 42,
        outgoingName: 'GitLab Support Bot',
        projectKey: 'key',
      };

      expect(wrapper.emitted('save')[0]).toEqual([payload]);
    });
  });

  describe('when isEnabled=false', () => {
    beforeEach(() => {
      wrapper = createComponent({
        props: { isEnabled: false },
      });
    });

    it('does not render email panel', () => {
      expect(findIncomingEmailLabel().exists()).toBe(false);
    });

    it('does not render template dropdown', () => {
      expect(findTemplateDropdown().exists()).toBe(false);
    });

    it('does not render template save button', () => {
      expect(findButton().exists()).toBe(false);
    });

    it('emits an event to turn on Service Desk when the toggle is clicked', async () => {
      findToggle().vm.$emit('change', false);

      await nextTick();

      expect(wrapper.emitted('toggle')[0]).toEqual([false]);
    });
  });
});

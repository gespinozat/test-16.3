import { mountExtended } from 'helpers/vue_test_utils_helper';
import BranchMoreDropdown from '~/branches/components/branch_more_actions.vue';
import eventHub from '~/branches/event_hub';

describe('Delete branch button', () => {
  let wrapper;
  let eventHubSpy;

  const findCompareButton = () => wrapper.findByTestId('compare-branch-button');
  const findDeleteButton = () => wrapper.findByTestId('delete-branch-button');

  const createComponent = (props = {}) => {
    wrapper = mountExtended(BranchMoreDropdown, {
      propsData: {
        branchName: 'test',
        defaultBranchName: 'main',
        canDeleteBranch: true,
        isProtectedBranch: false,
        merged: false,
        comparePath: '/path/to/branch',
        deletePath: '/path/to/branch',
        ...props,
      },
    });
  };

  beforeEach(() => {
    eventHubSpy = jest.spyOn(eventHub, '$emit');
  });

  it('renders the compare action', () => {
    createComponent();

    expect(findCompareButton().exists()).toBe(true);
    expect(findCompareButton().text()).toBe('Compare');
  });

  it('renders the delete action', () => {
    createComponent();

    expect(findDeleteButton().exists()).toBe(true);
    expect(findDeleteButton().text()).toBe('Delete branch');
  });

  it('renders a different text for a protected branch', () => {
    createComponent({ isProtectedBranch: true });

    expect(findDeleteButton().text()).toBe('Delete protected branch');
  });

  it('emits the data to eventHub when button is clicked', async () => {
    createComponent({ merged: true });

    await findDeleteButton().trigger('click');

    expect(eventHubSpy).toHaveBeenCalledWith('openModal', {
      branchName: 'test',
      defaultBranchName: 'main',
      deletePath: '/path/to/branch',
      isProtectedBranch: false,
      merged: true,
    });
  });

  it('doesn`t render the delete action when user cannot delete branch', () => {
    createComponent({ canDeleteBranch: false });

    expect(findDeleteButton().exists()).toBe(false);
  });
});

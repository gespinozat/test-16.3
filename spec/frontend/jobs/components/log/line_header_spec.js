import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import setWindowLocation from 'helpers/set_window_location_helper';
import DurationBadge from '~/jobs/components/log/duration_badge.vue';
import LineHeader from '~/jobs/components/log/line_header.vue';
import LineNumber from '~/jobs/components/log/line_number.vue';

describe('Job Log Header Line', () => {
  let wrapper;

  const data = {
    line: {
      content: [
        {
          text: 'Running with gitlab-runner 12.1.0 (de7731dd)',
          style: 'term-fg-l-green',
        },
      ],
      lineNumber: 76,
    },
    isClosed: true,
    path: '/jashkenas/underscore/-/jobs/335',
  };

  const createComponent = (props = {}) => {
    wrapper = mount(LineHeader, {
      propsData: {
        ...props,
      },
    });
  };

  describe('line', () => {
    beforeEach(() => {
      createComponent(data);
    });

    it('renders the line number component', () => {
      expect(wrapper.findComponent(LineNumber).exists()).toBe(true);
    });

    it('renders a span the provided text', () => {
      expect(wrapper.find('span').text()).toBe(data.line.content[0].text);
    });

    it('renders the provided style as a class attribute', () => {
      expect(wrapper.find('span').classes()).toContain(data.line.content[0].style);
    });
  });

  describe('when isCloses is true', () => {
    beforeEach(() => {
      createComponent({ ...data, isClosed: true });
    });

    it('sets icon name to be chevron-lg-right', () => {
      expect(wrapper.vm.iconName).toEqual('chevron-lg-right');
    });
  });

  describe('when isCloses is false', () => {
    beforeEach(() => {
      createComponent({ ...data, isClosed: false });
    });

    it('sets icon name to be chevron-lg-down', () => {
      expect(wrapper.vm.iconName).toEqual('chevron-lg-down');
    });
  });

  describe('on click', () => {
    beforeEach(() => {
      createComponent(data);
    });

    it('emits toggleLine event', async () => {
      wrapper.trigger('click');

      await nextTick();
      expect(wrapper.emitted().toggleLine.length).toBe(1);
    });
  });

  describe('with duration', () => {
    beforeEach(() => {
      createComponent({ ...data, duration: '00:10' });
    });

    it('renders the duration badge', () => {
      expect(wrapper.findComponent(DurationBadge).exists()).toBe(true);
    });
  });

  describe('line highlighting', () => {
    describe('with hash', () => {
      beforeEach(() => {
        setWindowLocation(`http://foo.com/root/ci-project/-/jobs/6353#L77`);

        createComponent(data);
      });

      it('highlights line', () => {
        expect(wrapper.classes()).toContain('gl-bg-gray-700');
      });
    });

    describe('without hash', () => {
      beforeEach(() => {
        setWindowLocation(`http://foo.com/root/ci-project/-/jobs/6353`);

        createComponent(data);
      });

      it('does not highlight line', () => {
        expect(wrapper.classes()).not.toContain('gl-bg-gray-700');
      });
    });
  });
});

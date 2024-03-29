<script>
import { GlBadge, GlIcon, GlAvatar, GlButton, GlLink } from '@gitlab/ui';
import { REPORT_HEADER_I18N, STATUS_OPEN, STATUS_CLOSED } from '../constants';
import ReportActions from './report_actions.vue';

export default {
  name: 'ReportHeader',
  components: {
    GlBadge,
    GlIcon,
    GlAvatar,
    GlButton,
    GlLink,
    ReportActions,
  },
  props: {
    user: {
      type: Object,
      required: true,
    },
    report: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      state: this.report.status,
    };
  },
  computed: {
    isOpen() {
      return this.state === STATUS_OPEN;
    },
    badgeClass() {
      return this.isOpen ? 'issuable-status-badge-open' : 'issuable-status-badge-closed';
    },
    badgeVariant() {
      return this.isOpen ? 'success' : 'info';
    },
    badgeText() {
      return REPORT_HEADER_I18N[this.state];
    },
    badgeIcon() {
      return this.isOpen ? 'issues' : 'issue-closed';
    },
  },
  methods: {
    closeReport() {
      this.state = STATUS_CLOSED;
    },
  },
  i18n: REPORT_HEADER_I18N,
};
</script>

<template>
  <header
    class="gl-py-4 gl-border-b gl-display-flex gl-justify-content-space-between gl-xs-flex-direction-column"
  >
    <div class="gl-display-flex gl-align-items-center">
      <gl-badge
        class="issuable-status-badge gl-mr-3"
        :class="badgeClass"
        :variant="badgeVariant"
        :aria-label="badgeText"
      >
        <gl-icon :name="badgeIcon" class="gl-badge-icon" />
        <span class="gl-display-none gl-sm-display-block gl-ml-2">{{ badgeText }}</span>
      </gl-badge>
      <gl-avatar :size="48" :src="user.avatarUrl" />
      <h1 class="gl-font-size-h-display gl-my-0 gl-ml-3">
        {{ user.name }}
      </h1>
      <gl-link :href="user.path" class="gl-ml-3"> @{{ user.username }} </gl-link>
    </div>
    <nav
      class="gl-display-flex gl-sm-align-items-center gl-mt-4 gl-sm-mt-0 gl-xs-flex-direction-column"
    >
      <gl-button :href="user.adminPath">
        {{ $options.i18n.adminProfile }}
      </gl-button>
      <report-actions
        :user="user"
        :report="report"
        class="gl-sm-ml-3 gl-mt-3 gl-sm-mt-0"
        @closeReport="closeReport"
        v-on="$listeners"
      />
    </nav>
  </header>
</template>

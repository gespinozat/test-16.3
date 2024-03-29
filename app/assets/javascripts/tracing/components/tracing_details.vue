<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import { visitUrl, isSafeURL } from '~/lib/utils/url_utility';

export default {
  components: {
    GlLoadingIcon,
  },
  i18n: {
    error: s__('Tracing|Failed to load trace details.'),
  },
  props: {
    observabilityClient: {
      required: true,
      type: Object,
    },
    traceId: {
      required: true,
      type: String,
    },
    tracingIndexUrl: {
      required: true,
      type: String,
      validator: (val) => isSafeURL(val),
    },
  },
  data() {
    return {
      trace: null,
      loading: false,
    };
  },
  created() {
    this.validateAndFetch();
  },
  methods: {
    async validateAndFetch() {
      if (!this.traceId) {
        createAlert({
          message: this.$options.i18n.error,
        });
      }
      this.loading = true;
      try {
        const enabled = await this.observabilityClient.isTracingEnabled();
        if (enabled) {
          await this.fetchTrace();
        } else {
          this.goToTracingIndex();
        }
      } catch (e) {
        createAlert({
          message: this.$options.i18n.error,
        });
      } finally {
        this.loading = false;
      }
    },
    async fetchTrace() {
      this.loading = true;
      try {
        this.trace = await this.observabilityClient.fetchTrace(this.traceId);
      } catch (e) {
        createAlert({
          message: this.$options.i18n.error,
        });
      } finally {
        this.loading = false;
      }
    },
    goToTracingIndex() {
      visitUrl(this.tracingIndexUrl);
    },
  },
};
</script>

<template>
  <div v-if="loading" class="gl-py-5">
    <gl-loading-icon size="lg" />
  </div>

  <!-- TODO Replace with actual trace-details component-->
  <div v-else-if="trace" data-testid="trace-details">
    <p>{{ tracingIndexUrl }}</p>
    <p>{{ trace }}</p>
  </div>
</template>

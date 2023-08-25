export const SNOWPLOW_JS_SOURCE = 'gitlab-javascript';

export const DEFAULT_SNOWPLOW_OPTIONS = {
  namespace: 'gl',
  hostname: window.location.hostname,
  cookieDomain: window.location.hostname,
  appId: '',
  respectDoNotTrack: true,
  eventMethod: 'post',
  contexts: { webPage: true, performanceTiming: true },
  formTracking: false,
  linkClickTracking: false,
  plugins: window.snowplowPlugins || [],
  formTrackingConfig: {
    forms: { allow: [] },
    fields: { allow: [] },
  },
};

export const ACTION_ATTR_SELECTOR = '[data-track-action]';
export const LOAD_ACTION_ATTR_SELECTOR = '[data-track-action="render"]';
export const INTERNAL_EVENTS_SELECTOR = '[data-event-tracking]';
export const LOAD_INTERNAL_EVENTS_SELECTOR = '[data-event-tracking-load="true"]';

export const URLS_CACHE_STORAGE_KEY = 'gl-snowplow-pseudonymized-urls';

export const REFERRER_TTL = 24 * 60 * 60 * 1000;

export const GOOGLE_ANALYTICS_ID_COOKIE_NAME = '_ga';

export const GITLAB_INTERNAL_EVENT_CATEGORY = 'InternalEventTracking';

export const SERVICE_PING_SCHEMA = 'iglu:com.gitlab/gitlab_service_ping/jsonschema/1-0-0';

<script>
import {
  GlButton,
  GlDrawer,
  GlFormCheckbox,
  GlFormCombobox,
  GlFormGroup,
  GlFormSelect,
  GlFormTextarea,
  GlIcon,
  GlLink,
  GlSprintf,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { DRAWER_Z_INDEX } from '~/lib/utils/constants';
import { getContentWrapperHeight } from '~/lib/utils/dom_utils';
import { helpPagePath } from '~/helpers/help_page_helper';
import {
  defaultVariableState,
  ENVIRONMENT_SCOPE_LINK_TITLE,
  EXPANDED_VARIABLES_NOTE,
  FLAG_LINK_TITLE,
  VARIABLE_ACTIONS,
  variableOptions,
} from '../constants';
import CiEnvironmentsDropdown from './ci_environments_dropdown.vue';
import { awsTokenList } from './ci_variable_autocomplete_tokens';

const i18n = {
  addVariable: s__('CiVariables|Add Variable'),
  cancel: __('Cancel'),
  environments: __('Environments'),
  environmentScopeLinkTitle: ENVIRONMENT_SCOPE_LINK_TITLE,
  expandedField: s__('CiVariables|Expand variable reference'),
  expandedDescription: EXPANDED_VARIABLES_NOTE,
  flags: __('Flags'),
  flagsLinkTitle: FLAG_LINK_TITLE,
  key: __('Key'),
  maskedField: s__('CiVariables|Mask variable'),
  maskedDescription: s__(
    'CiVariables|Variable will be masked in job logs. Requires values to meet regular expression requirements.',
  ),
  protectedField: s__('CiVariables|Protect variable'),
  protectedDescription: s__(
    'CiVariables|Export variable to pipelines running on protected branches and tags only.',
  ),
  type: __('Type'),
  value: __('Value'),
};

export default {
  DRAWER_Z_INDEX,
  components: {
    CiEnvironmentsDropdown,
    GlButton,
    GlDrawer,
    GlFormCheckbox,
    GlFormCombobox,
    GlFormGroup,
    GlFormSelect,
    GlFormTextarea,
    GlIcon,
    GlLink,
    GlSprintf,
  },
  inject: ['environmentScopeLink'],
  props: {
    areEnvironmentsLoading: {
      type: Boolean,
      required: true,
    },
    environments: {
      type: Array,
      required: false,
      default: () => [],
    },
    hasEnvScopeQuery: {
      type: Boolean,
      required: true,
    },
    mode: {
      type: String,
      required: true,
      validator(val) {
        return VARIABLE_ACTIONS.includes(val);
      },
    },
  },
  data() {
    return {
      key: defaultVariableState.key,
      variableType: defaultVariableState.variableType,
    };
  },
  computed: {
    getDrawerHeaderHeight() {
      return getContentWrapperHeight();
    },
  },
  methods: {
    close() {
      this.$emit('close-form');
    },
  },
  awsTokenList,
  flagLink: helpPagePath('ci/variables/index', {
    anchor: 'define-a-cicd-variable-in-the-ui',
  }),
  i18n,
  variableOptions,
};
</script>
<template>
  <gl-drawer
    open
    data-testid="ci-variable-drawer"
    :header-height="getDrawerHeaderHeight"
    :z-index="$options.DRAWER_Z_INDEX"
    @close="close"
  >
    <template #title>
      <h2 class="gl-m-0">{{ $options.i18n.addVariable }}</h2>
    </template>
    <gl-form-group
      :label="$options.i18n.type"
      label-for="ci-variable-type"
      class="gl-border-none gl-mb-n5"
    >
      <gl-form-select
        id="ci-variable-type"
        v-model="variableType"
        :options="$options.variableOptions"
      />
    </gl-form-group>
    <gl-form-group
      class="gl-border-none gl-mb-n5"
      label-for="ci-variable-env"
      data-testid="environment-scope"
    >
      <template #label>
        <div class="gl-display-flex gl-align-items-center">
          <span class="gl-mr-2">
            {{ $options.i18n.environments }}
          </span>
          <gl-link
            class="gl-display-flex"
            :title="$options.i18n.environmentScopeLinkTitle"
            :href="environmentScopeLink"
            target="_blank"
            data-testid="environment-scope-link"
          >
            <gl-icon name="question-o" :size="14" />
          </gl-link>
        </div>
      </template>
      <ci-environments-dropdown
        class="gl-mb-5"
        :are-environments-loading="areEnvironmentsLoading"
        :environments="environments"
        :has-env-scope-query="hasEnvScopeQuery"
        selected-environment-scope=""
      />
    </gl-form-group>
    <gl-form-group class="gl-border-none gl-mb-n8">
      <template #label>
        <div class="gl-display-flex gl-align-items-center gl-mb-n3">
          <span class="gl-mr-2">
            {{ $options.i18n.flags }}
          </span>
          <gl-link
            class="gl-display-flex"
            :title="$options.i18n.flagsLinkTitle"
            :href="$options.flagLink"
            target="_blank"
          >
            <gl-icon name="question-o" :size="14" />
          </gl-link>
        </div>
      </template>
      <gl-form-checkbox data-testid="ci-variable-protected-checkbox">
        {{ $options.i18n.protectedField }}
        <p class="gl-text-secondary">
          {{ $options.i18n.protectedDescription }}
        </p>
      </gl-form-checkbox>
      <gl-form-checkbox data-testid="ci-variable-masked-checkbox">
        {{ $options.i18n.maskedField }}
        <p class="gl-text-secondary">{{ $options.i18n.maskedDescription }}</p>
      </gl-form-checkbox>
      <gl-form-checkbox data-testid="ci-variable-expanded-checkbox">
        {{ $options.i18n.expandedField }}
        <p class="gl-text-secondary">
          <gl-sprintf :message="$options.i18n.expandedDescription" class="gl-text-secondary">
            <template #code="{ content }">
              <code>{{ content }}</code>
            </template>
          </gl-sprintf>
        </p>
      </gl-form-checkbox>
    </gl-form-group>
    <gl-form-combobox
      v-model="key"
      :token-list="$options.awsTokenList"
      :label-text="$options.i18n.key"
      class="gl-border-none gl-pb-0! gl-mb-n5"
      data-testid="pipeline-form-ci-variable-key"
      data-qa-selector="ci_variable_key_field"
    />
    <gl-form-group
      :label="$options.i18n.value"
      label-for="ci-variable-value"
      class="gl-border-none gl-mb-n2"
    >
      <gl-form-textarea
        id="ci-variable-value"
        class="gl-border-none gl-font-monospace!"
        rows="3"
        max-rows="10"
        data-testid="pipeline-form-ci-variable-value"
        data-qa-selector="ci_variable_value_field"
        spellcheck="false"
      />
    </gl-form-group>
    <div class="gl-display-flex gl-justify-content-end">
      <gl-button category="primary" class="gl-mr-3" data-testid="cancel-button" @click="close"
        >{{ $options.i18n.cancel }}
      </gl-button>
      <gl-button category="primary" variant="confirm" data-testid="confirm-button"
        >{{ $options.i18n.addVariable }}
      </gl-button>
    </div>
  </gl-drawer>
</template>

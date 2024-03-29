<script>
import { GlDisclosureDropdownGroup, GlDisclosureDropdownItem, GlIcon } from '@gitlab/ui';
import { truncateNamespace } from '~/lib/utils/text_utility';
import { getItemsFromLocalStorage, removeItemFromLocalStorage } from '~/super_sidebar/utils';
import FrequentItem from './frequent_item.vue';

export default {
  name: 'FrequentlyVisitedItems',
  components: {
    GlDisclosureDropdownGroup,
    GlDisclosureDropdownItem,
    GlIcon,
    FrequentItem,
  },
  props: {
    emptyStateText: {
      type: String,
      required: true,
    },
    groupName: {
      type: String,
      required: true,
    },
    maxItems: {
      type: Number,
      required: true,
    },
    storageKey: {
      type: String,
      required: false,
      default: null,
    },
    viewAllItemsText: {
      type: String,
      required: true,
    },
    viewAllItemsIcon: {
      type: String,
      required: true,
    },
    viewAllItemsPath: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      items: getItemsFromLocalStorage({
        storageKey: this.storageKey,
        maxItems: this.maxItems,
      }),
    };
  },
  computed: {
    formattedItems() {
      // Each item needs two different representations. One is for the
      // GlDisclosureDropdownItem, and the other is for the FrequentItem
      // renderer component inside it.
      return this.items.map((item) => ({
        forDropdown: {
          id: item.id,

          // The text field satsifies GlDisclosureDropdownItem's prop
          // validator, and the href field ensures it renders a link.
          text: item.name,
          href: item.webUrl,
        },
        forRenderer: {
          id: item.id,
          title: item.name,
          subtitle: truncateNamespace(item.namespace),
          avatar: item.avatarUrl,
        },
      }));
    },
    showEmptyState() {
      return this.items.length === 0;
    },
    viewAllItem() {
      return {
        text: this.viewAllItemsText,
        href: this.viewAllItemsPath,
      };
    },
  },
  created() {
    if (!this.storageKey) {
      this.$emit('nothing-to-render');
    }
  },
  methods: {
    removeItem(item) {
      removeItemFromLocalStorage({
        storageKey: this.storageKey,
        item,
      });

      this.items = this.items.filter((i) => i.id !== item.id);
    },
  },
};
</script>

<template>
  <gl-disclosure-dropdown-group v-if="storageKey" v-bind="$attrs">
    <template #group-label>{{ groupName }}</template>

    <gl-disclosure-dropdown-item
      v-for="item of formattedItems"
      :key="item.forDropdown.id"
      :item="item.forDropdown"
      class="show-on-focus-or-hover--context"
    >
      <template #list-item
        ><frequent-item :item="item.forRenderer" @remove="removeItem"
      /></template>
    </gl-disclosure-dropdown-item>

    <gl-disclosure-dropdown-item v-if="showEmptyState" class="gl-cursor-text">
      <span class="gl-text-gray-500 gl-font-sm gl-my-3 gl-mx-3">{{ emptyStateText }}</span>
    </gl-disclosure-dropdown-item>

    <gl-disclosure-dropdown-item key="all" :item="viewAllItem">
      <template #list-item>
        <span>
          <gl-icon :name="viewAllItemsIcon" class="gl-w-6!" />
          {{ viewAllItemsText }}
        </span>
      </template>
    </gl-disclosure-dropdown-item>
  </gl-disclosure-dropdown-group>
</template>

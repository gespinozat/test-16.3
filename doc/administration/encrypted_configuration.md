---
stage: Systems
group: Distribution
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments"
type: reference
---

# Encrypted Configuration **(FREE SELF)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/45712) in GitLab 13.7.

GitLab can read settings for certain features from encrypted settings files. The supported features are:

- [Incoming email `user` and `password`](incoming_email.md#use-encrypted-credentials).
- [LDAP `bind_dn` and `password`](auth/ldap/index.md#use-encrypted-credentials).
- [Service Desk email `user` and `password`](../user/project/service_desk/index.md#use-encrypted-credentials).
- [SMTP `user_name` and `password`](raketasks/smtp.md#secrets).

To enable the encrypted configuration settings, a new base key must be generated for
`encrypted_settings_key_base`. The secret can be generated in the following ways:

- For Linux package installations, the new secret is automatically generated for you, but you must ensure your
  `/etc/gitlab/gitlab-secrets.json` contains the same values on all nodes.
- For Helm chart installations, the new secret is automatically generated if you have the `shared-secrets` chart enabled.
  Otherwise, you need to follow the [secrets guide for adding the secret](https://docs.gitlab.com/charts/installation/secrets.html#gitlab-rails-secret).
- For self-compiled installations, the new secret can be generated by running:

  ```shell
  bundle exec rake gitlab:env:info RAILS_ENV=production GITLAB_GENERATE_ENCRYPTED_SETTINGS_KEY_BASE=true
  ```

  This prints general information on the GitLab instance and generates the key in `<path-to-gitlab-rails>/config/secrets.yml`.
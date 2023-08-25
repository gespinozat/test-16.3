---
stage: Verify
group: Runner SaaS
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
type: reference
---

# Runner SaaS **(FREE SAAS)**

You can run your CI/CD jobs on GitLab.com using SaaS runners hosted by GitLab to seamlessly build, test and deploy
your application on different environments.
These runners fully integrated with GitLab.com and are enabled by default for all projects, with no configuration required.
Your jobs can run on:

- [Linux runners](saas/linux_saas_runner.md)
- [GPU runners](saas/gpu_saas_runner.md)
- [Windows runners](saas/windows_saas_runner.md) ([Beta](../../policy/experiment-beta-support.md#beta))
- [macOS runners](saas/macos_saas_runner.md) ([Beta](../../policy/experiment-beta-support.md#beta))

Refer to the compute minutes [cost factor](../../ci/pipelines/cicd_minutes.md#cost-factor) for the cost factor applied to the machine type based on size.
The number of minutes you can use on these runners depends on the [maximum number of compute minutes](../pipelines/cicd_minutes.md)
in your [subscription plan](https://about.gitlab.com/pricing/).

## How SaaS runners work

When you use SaaS runners:

- Each of your jobs runs in a newly provisioned VM, which is dedicated to the specific job.
- The VM is active only for the duration of the job and immediately deleted. This means that any changes that your job makes to the virtual machine will not be available to a subsequent job.
- The virtual machine where your job runs has `sudo` access with no password.
- The storage is shared by the operating system, the image with pre-installed software, and a copy of your cloned repository.
This means that the available free disk space for your jobs to use is reduced.
- [Untagged](../../ci/runners/configure_runners.md#use-tags-to-control-which-jobs-a-runner-can-run) jobs automatically run in containers
on the `small` Linux runners.
- The objective is to make 90% of CI jobs start executing in 120 seconds or less. The error rate target will be less than 0.5%.

NOTE:
Jobs handled by SaaS runners on GitLab.com **time out after 3 hours**, regardless of the timeout configured in a project.

## Security for SaaS runners

GitLab SaaS runners on Linux and Windows run on Google Compute Platform.
The [Google Infrastructure Security Design Overview whitepaper](https://cloud.google.com/docs/security/infrastructure/design/resources/google_infrastructure_whitepaper_fa.pdf)
provides an overview of how Google designs security into its technical infrastructure.
The GitLab [Trust Center](https://about.gitlab.com/security/) and
[GitLab Security Compliance Controls](https://about.staging.gitlab.com/handbook/engineering/security/security-assurance/security-compliance/sec-controls.html)
pages provide an overview of the security and compliance controls that govern the GitLab SaaS runners.

The following section provides an overview of the additional built-in layers that harden the security of the GitLab Runner SaaS CI build environment.

### Security of CI job execution

A dedicated temporary runner VM hosts and runs each CI job. On GitLab SaaS, two CI jobs never run on the same VM.

In this example, there are three jobs in the project's pipeline. Therefore, there are three temporary VMs used to run that pipeline, or one VM per job.

![Job isolation](img/build_isolation.png)

The build job ran on `runner-ns46nmmj-project-43717858`, test job on `f131a6a2runner-new2m-od-project-43717858` and deploy job on `runner-tmand5m-project-43717858`.

GitLab sends the command to remove the temporary runner VM to the Google Compute API immediately after the CI job completes. The [Google Compute Engine hypervisor](https://cloud.google.com/blog/products/gcp/7-ways-we-harden-our-kvm-hypervisor-at-google-cloud-security-in-plaintext)
takes over the task of securely deleting the virtual machine and associated data.

### Network security of CI job VMs

- Firewall rules only allow outbound communication from the temporary VM to the public internet.
- Inbound communication from the public internet to the temporary VM is not allowed.
- Firewall rules do not permit communication between VMs.
- The only internal communication allowed to the temporary VMs is from the runner manager.

import initPipelineSchedulesFormApp from '~/ci/pipeline_schedules/mount_pipeline_schedules_form_app';
import initForm from '../shared/init_form';

if (gon.features?.pipelineSchedulesVue) {
  initPipelineSchedulesFormApp('#pipeline-schedules-form-edit', true);
} else {
  initForm();
}
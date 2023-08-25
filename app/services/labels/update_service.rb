# frozen_string_literal: true

module Labels
  class UpdateService < Labels::BaseService
    def initialize(params = {})
      @params = params.to_h.dup.with_indifferent_access
    end

    # returns the updated label
    def execute(label)
      params[:name] = params.delete(:new_name) if params.key?(:new_name)
      params[:color] = convert_color_name_to_hex if params[:color].present?
      params.delete(:lock_on_merge) unless allow_lock_on_merge?(label)

      label.update(params)
      label
    end

    private

    def allow_lock_on_merge?(label)
      return if label.template?
      return unless label.respond_to?(:parent_container)

      Feature.enabled?(:enforce_locked_labels_on_merge, label.parent_container, type: :ops)
    end
  end
end

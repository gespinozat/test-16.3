# frozen_string_literal: true

module MergeRequests
  class MergeBaseService < MergeRequests::BaseService
    include Gitlab::Utils::StrongMemoize

    MergeError = Class.new(StandardError)

    attr_reader :merge_request

    # Overridden in EE.
    def hooks_validation_pass?(merge_request, validate_squash_message: false)
      true
    end

    # Overridden in EE.
    def hooks_validation_error(merge_request, validate_squash_message: false)
      # No-op
    end

    def source
      strong_memoize(:source) do
        if merge_request.squash_on_merge?
          squash_sha!
        else
          merge_request.diff_head_sha
        end
      end
    end

    private

    def check_source
      unless source
        raise_error('No source for merge')
      end
    end

    # Overridden in EE.
    def check_size_limit
      # No-op
    end

    # Overridden in EE.
    def error_check!
      # No-op
    end

    def raise_error(message)
      raise MergeError, message
    end

    def handle_merge_error(*args)
      # No-op
    end

    def commit_message
      params[:commit_message] ||
        merge_request.default_merge_commit_message(user: current_user)
    end

    def squash_sha!
      squash_result = ::MergeRequests::SquashService.new(
        merge_request: merge_request,
        current_user: current_user,
        commit_message: params[:squash_commit_message]
      ).execute

      case squash_result[:status]
      when :success
        squash_result[:squash_sha]
      when :error
        raise ::MergeRequests::MergeService::MergeError, squash_result[:message]
      end
    end
  end
end

MergeRequests::MergeBaseService.prepend_mod_with('MergeRequests::MergeBaseService')

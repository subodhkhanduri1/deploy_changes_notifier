require_relative 'error_raiser'
require 'English'

module DeployChanges
  class Validator

    def initialize(notifier_object, error_raiser)
      self.notifier = notifier_object
      self.error_raiser = error_raiser
    end

    def validate_repo_url(repo_url)
      error_raiser.raise_invalid_git_repo_url_error(
        repo_url
      ) unless repo_url =~ git_repo_url_regex
    end

    def validate_tag_prefix(prefix)
      error_raiser.raise_tag_prefix_missing_error unless non_empty_string?(prefix)
    end

    def validate_deploy_job_build_number(job_build_number)
      return if non_empty_string?(job_build_number) && job_build_number.to_i > 0

      error_raiser.raise_deploy_job_build_number_missing_error
    end

    def validate_deploy_job_name(job_name)
      error_raiser.raise_deploy_job_name_missing_error unless non_empty_string?(job_name)
    end

    def validate_slack_channel_name(channel_name)
      error_raiser.raise_slack_channel_missing_error unless non_empty_string?(channel_name)
    end

    def validate_new_tag(new_tag_name)
      return if non_empty_string?(new_tag_name) && git_tag_exists?(new_tag_name)

      error_raiser.raise_invalid_tag_name_error(new_tag_name)
    end

    def validate_slack_api_token(token)
      return if non_empty_string?(token)

      error_raiser.raise_slack_api_token_missing_error
    end

    private

    attr_accessor :notifier, :error_raiser

    def git_repo_url_regex
      /^https:\/\/github.com\/(.*)\/(.*)/
    end

    def git_tag_exists?(tag_name)
      tag_command_output = `cd #{notifier.git_repo_directory} && git tag -l #{tag_name}`

      $CHILD_STATUS.success? && tag_command_output.split("\n").count == 1
    end

    def non_empty_string?(string_var)
      string_var.is_a?(String) && !string_var.empty?
    end

  end
end

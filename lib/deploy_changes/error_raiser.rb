require_relative 'errors/errors'

module DeployChanges
  class ErrorRaiser

    def raise_slack_channel_missing_error
      fail(
        Errors::SlackChannelMissing.new,
        "SLACK_CHANNEL env variable missing. Ex: '#test_channel'"
      )
    end

    def raise_slack_api_token_missing_error
      fail(
        Errors::SlackApiTokenMissing.new,
        "SLACK_BOT_API_TOKEN env variable missing"
      )
    end

    def raise_invalid_git_repo_url_error(repo_url)
      fail(
        Errors::InvalidGitRepoUrl.new(repo_url),
        "'#{repo_url}' is not a valid SQ Git Repo URL"
      )
    end

    def raise_invalid_tag_name_error(tag_name)
      message = if tag_name.nil? || tag_name.empty?
                  "Git tag name missing"
                else
                  "Git tag '#{tag_name}' not found"
                end

      fail Errors::InvalidTagName.new, message
    end

    def raise_git_repo_clone_failed_error(git_repo_url)
      fail(
        Errors::GitRepoCloneFailed.new,
        "Git clone from '#{git_repo_url}' failed"
      )
    end

    def raise_deploy_job_build_number_missing_error
      fail(
        Errors::DeployJobBuildNumberMissing.new,
        "DEPLOY_JOB_BUILD_NUMBER env variable missing."
      )
    end

    def raise_deploy_job_name_missing_error
      fail(
        Errors::DeployJobNameMissing.new,
        "DEPLOY_JOB_NAME env variable missing."
      )
    end

    def raise_tag_prefix_missing_error
      fail(
        Errors::TagPrefixMissingError.new,
        "TAG_PREFIX env variable missing."
      )
    end

  end
end

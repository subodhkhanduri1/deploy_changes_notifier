# This class compares the latest deployed tag and the one deployed before it,
# and sends a Slack notification with the list of all new commits deployed
#
# Requirements:
#
#   The following environment variables must be supplied
#     - GIT_REPO_URL: The url of the deployed repository
#     - TAG_PREFIX: The prefix before the build number
#       (Ex: "app-stg-")
#     - DEPLOY_JOB_NAME: The name of the deploy job that was triggered
#     - DEPLOY_JOB_BUILD_NUMBER: The latest build number of the deploy job
#     - SLACK_BOT_API_TOKEN: The access token of the Slack bot which will post the notification
#     - SLACK_CHANNEL: The Slack channel to post to
#
# Assumptions:
#
# - The DEPLOY_JOB_BUILD_NUMBER is always of the latest stable build

require 'slack-ruby-client'
require_relative 'validator'

module DeployChanges

  class Notifier

    attr_reader(
      :git_repo_url,
      :tag_prefix,
      :slack_channel,
      :deploy_job_name,
      :deploy_job_build_number,
      :new_tag_name
    )

    def initialize(&block)
      create_required_objects

      config = build_config(&block)
      set_required_values(config)

      configure_slack
    end

    def send_deploy_changes_notification
      cleanup_repo
      clone_repo
      send_slack_notification
    rescue StandardError => e
      raise e
    ensure
      cleanup_repo
    end

    def git_repo_directory
      @git_repo_directory ||= git_repo_url
                                .split('/')
                                .last
                                .gsub('.git', '')
    end

    private

    attr_writer :new_tag_name
    attr_accessor :validator, :error_raiser, :slack_bot_api_token

    def create_required_objects
      self.error_raiser = ErrorRaiser.new
      self.validator = Validator.new(self, error_raiser)
    end

    def build_config(&block)
      config = OpenStruct.new

      yield config if block_given?

      config
    end

    def set_required_values(config)
      self.git_repo_url = config.git_repo_url || ENV["GIT_REPO_URL"]
      self.tag_prefix = config.tag_prefix || ENV["TAG_PREFIX"]

      self.deploy_job_build_number = config.deploy_job_build_number || ENV["DEPLOY_JOB_BUILD_NUMBER"]
      self.deploy_job_name = config.deploy_job_name || ENV["DEPLOY_JOB_NAME"]

      self.new_tag_name = tag_prefix + deploy_job_build_number

      self.slack_channel = config.slack_channel || ENV["SLACK_CHANNEL"]
      self.slack_bot_api_token = config.slack_bot_api_token || ENV["SLACK_BOT_API_TOKEN"]
    end

    def configure_slack
      validator.validate_slack_api_token(ENV["SLACK_BOT_API_TOKEN"])

      Slack.configure do |config|
        config.token = ENV["SLACK_BOT_API_TOKEN"]
      end
    end

    def send_slack_notification
      slack_client.auth_test

      slack_client.chat_postMessage(
        channel: slack_channel,
        text: deploy_changes_message,
        as_user: true
      )
    end

    def deploy_changes_message
      deploy_changes_array = deploy_changes_list

      message = "*#{deploy_job_name} \##{deploy_job_build_number} changes:*\n"

      message += if deploy_changes_array.empty?
                   " - No changes"
                 else
                   deploy_changes_array
                   .map { |commit_message| " - " + commit_message }
                   .join("\n")
                 end

      puts message

      message
    end

    def deploy_changes_list
      return [] if previous_tag_name.nil? || previous_tag_name.empty?

      deploy_changes_string = deploy_changes_command_output
      return [] unless last_command_successful?

      deploy_changes_string.split("\n")
    end

    def deploy_changes_command_output
      `#{deploy_changes_command}`
    end

    def deploy_changes_command
      validator.validate_new_tag(new_tag_name)

      puts "New tag name: #{new_tag_name}"

      "cd #{git_repo_directory} && git log  --pretty=oneline --no-merges --format=\"%s [%an]\" #{previous_tag_name}...#{new_tag_name}"
    end

    def previous_tag_name
      return @previous_tag_name if @previous_tag_name

      previous_tag = previous_tag_from_tags_list(tags_list)

      puts "Previous tag name: #{previous_tag}"
      @previous_tag_name = previous_tag
    end

    def tags_list
      tags = tags_list_command_output
      tags.split("\n")
        .reverse
        .map { |ref| ref.gsub("refs/tags/", "") }
    end

    def tags_list_command_output
      `cd #{git_repo_directory} && git for-each-ref --sort=taggerdate --format="%(refname)" refs/tags/#{tag_prefix}*`
    end

    def previous_tag_from_tags_list(tags_list)
      tags_list.each_with_index do |tag, index|
        return tags_list[index + 1] if tag == new_tag_name
      end
    end

    def clone_repo
      puts "Cloning from '#{git_repo_url}'"

      `git clone #{git_repo_url}`

      unless last_command_successful? && Dir.exist?(repo_directory_name)
        error_raiser.raise_git_repo_clone_failed_error
      end
    end

    def last_command_successful?
      $CHILD_STATUS.success?
    end

    def cleanup_repo
      return true unless Dir.exist?(git_repo_directory)

      puts "Deleting '#{git_repo_directory}' folder"

      `rm -rf #{git_repo_directory}`
    end

    def git_repo_url=(repo_url)
      validator.validate_repo_url(repo_url)

      @git_repo_url = repo_url
    end

    def tag_prefix=(prefix)
      validator.validate_tag_prefix(prefix)

      @tag_prefix = prefix
    end

    def deploy_job_build_number=(job_build_number)
      validator.validate_deploy_job_build_number(job_build_number)

      @deploy_job_build_number = job_build_number
    end

    def deploy_job_name=(job_name)
      validator.validate_deploy_job_name(job_name)

      @deploy_job_name = job_name
    end

    def slack_channel=(channel_name)
      validator.validate_slack_channel_name(channel_name)

      @slack_channel = channel_name
    end

    def slack_client
      @slack_client ||= Slack::Web::Client.new
    end

  end

end

module DeployChanges
  module Errors

    class InvalidGitRepoUrl < StandardError; end

    class InvalidTagName < StandardError; end

    class DeployJobNameMissing < StandardError; end

    class DeployJobBuildNumberMissing < StandardError; end

    class TagPrefixMissingError < StandardError; end

    class SlackChannelMissing < StandardError; end

    class SlackApiTokenMissing < StandardError; end

    class GitRepoCloneFailed < StandardError; end

  end
end

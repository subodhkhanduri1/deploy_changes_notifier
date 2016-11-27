# DeployChangesNotifier

Send notifications for the changes deployed in each build, compared to the previous build. It is a good practise to create GIT tags for each deployment. DeployChangesNotifier compares the latest deployed tag with the previous deployed tag and sends the list of new commits deployed to a Slack channel. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deploy_changes_notifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deploy_changes_notifier

Or use the github url:

```ruby
gem 'deploy_changes_notifier', git: "https://github.com/subodhkhanduri1/deploy_changes_notifier.git"
```

## Usage

Require the gem

```ruby
require 'deploy_changes'
```

Send notification

```ruby
notifier = DeployChanges::Notifier.new do |config|
  config.git_repo_url = 'https://github.com/<your_organization>/<your_repo_name>'
  # Tags are expected to be numbered in sequential order. Build numbers would work nicely.
  config.tag_prefix = 'app-prd-'
  config.deploy_job_name = '<your_deploy_job_name>'
  config.deploy_job_build_number = 3 # The latest deploy job build number
  config.slack_channel = 'Production'
  config.slack_bot_api_token = '<some_token>'
end

notifier.send_deploy_changes_notification
```

To supply the config parameters to a script, pass in environment variables with the same name as the config variables. If you pass in environment variables, there is no need to pass config variables in the constructor.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/subodhkhanduri1/deploy_changes_notifier.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


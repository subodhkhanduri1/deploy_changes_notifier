describe DeployChanges::Notifier do

  let(:slack_client) do
    double("Slack Client")
  end

  let(:validator) do
    double("Validator")
  end

  let(:tags_list) do
    [
      "app-stg-4",
      "app-stg-3",
      "app-stg-2",
      "app-stg-1"
    ]
  end

  before do
    allow(validator).to receive(:validate_repo_url)
    allow(validator).to receive(:validate_tag_prefix)
    allow(validator).to receive(:validate_deploy_job_build_number)
    allow(validator).to receive(:validate_deploy_job_name)
    allow(validator).to receive(:validate_slack_channel_name)
    allow(validator).to receive(:validate_new_tag)
    allow(validator).to receive(:validate_slack_api_token)

    allow(slack_client).to receive(:auth_test)
    allow(slack_client).to receive(:chat_postMessage)

    allow_any_instance_of(described_class).to receive(:slack_client) { slack_client }

    allow_any_instance_of(described_class).to receive(:validator) { validator }

    allow_any_instance_of(described_class).to receive(:cleanup_repo)
    allow_any_instance_of(described_class).to receive(:clone_repo)
  end

  context "#previous_tag_from_tags_list" do

    before do
      allow_any_instance_of(described_class).to receive(:tags_list) { tags_list }
      allow_any_instance_of(described_class).to receive(:tag_prefix) { 'app-stg-' }
    end

    it "sends the tag, deployed just before the build number, to STDOUT" do
      allow_any_instance_of(described_class).to receive(:deploy_job_build_number) { '3' }
      allow_any_instance_of(described_class).to receive(:deploy_changes_command_output) { '' }

      # Chain with 'and_call_original' if you want to see the output
      expect(STDOUT).to receive(:puts).with("Previous tag name: app-stg-2")
      expect(STDOUT).to receive(:puts).with(anything)
      subject.send_deploy_changes_notification
    end

    it "sends nil to STDOUT when previous deployed tag is not found" do
      allow_any_instance_of(described_class).to receive(:deploy_job_build_number) { '1' }
      allow_any_instance_of(described_class).to receive(:deploy_changes_command_output) { '' }

      # Chain with 'and_call_original' if you want to see the output
      expect(STDOUT).to receive(:puts).with("Previous tag name: ")
      expect(STDOUT).to receive(:puts).with(anything)
      subject.send_deploy_changes_notification
    end

  end

  context "#tags_list" do

    let(:tags_list_command_output) do
      tags_list.reverse.join("\n")
    end

    before do
      allow_any_instance_of(described_class).to receive(:tag_prefix) { 'app-stg-' }
    end

    it "returns the tags list in the latest first order" do
      allow_any_instance_of(described_class).to receive(:tags_list_command_output) do
        tags_list_command_output
      end
      allow_any_instance_of(described_class).to receive(:deploy_job_build_number) { '2' }
      allow_any_instance_of(described_class).to receive(:deploy_changes_command_output) { '' }

      expect(subject).to receive(:tags_list).and_return(tags_list)
      subject.send_deploy_changes_notification
    end

  end
end

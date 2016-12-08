describe DeployChanges::Validator do

  let(:test_notifier) { double('TestNotifier') }
  let(:test_error_raiser) { double('TestErrorRaiser') }

  subject { described_class.new(test_notifier, test_error_raiser) }

  context '#initialize' do
    it { expect(subject).to be_instance_of(described_class) }
  end

  context '#validate_repo_url' do
    context 'when repo url is not a valid Github repo url' do
      it 'raises invalid git repo url error' do
        repo_url = 'https://github.com/test'
        expect(test_error_raiser).to receive(:raise_invalid_git_repo_url_error).with(repo_url)
        subject.validate_repo_url(repo_url)
      end
    end

    context 'when repo url is a valid Github repo url' do
      it 'does not raise invalid git repo url error' do
        repo_url = 'https://github.com/test/test'
        expect(test_error_raiser).not_to receive(:raise_invalid_git_repo_url_error)
        expect(subject.validate_repo_url(repo_url)).to be_nil
      end
    end
  end

  missing_data_validators = [
    {
      name: 'tag prefix',
      function_name: 'validate_tag_prefix',
      error_raiser_function_name: 'raise_tag_prefix_missing_error'
    },
    {
      name: 'deploy job name',
      function_name: 'validate_deploy_job_name',
      error_raiser_function_name: 'raise_deploy_job_name_missing_error'
    },
    {
      name: 'slack api token',
      function_name: 'validate_slack_api_token',
      error_raiser_function_name: 'raise_slack_api_token_missing_error'
    }
  ]

  missing_data_validators.each do |missing_data_validator_hash|
    context "##{missing_data_validator_hash[:function_name]}" do
      context "when #{missing_data_validator_hash[:name]} is not a string" do
        it "raises #{missing_data_validator_hash[:name]} missing error" do
          expect(test_error_raiser).to(
            receive(missing_data_validator_hash[:error_raiser_function_name])
          )

          subject.public_send(missing_data_validator_hash[:function_name], 1)
        end
      end

      context "when #{missing_data_validator_hash[:name]} is an empty string" do
        it "raises #{missing_data_validator_hash[:name]} missing error" do
          expect(test_error_raiser).to(
            receive(missing_data_validator_hash[:error_raiser_function_name])
          )

          subject.public_send(missing_data_validator_hash[:function_name], "")
        end
      end

      context "when #{missing_data_validator_hash[:name]} is a non-empty string" do
        it "does not #{missing_data_validator_hash[:name]} name missing error" do
          expect(test_error_raiser).not_to(
            receive(missing_data_validator_hash[:error_raiser_function_name])
          )

          expect(
            subject.public_send(missing_data_validator_hash[:function_name], "test")
          ).to be_nil
        end
      end
    end
  end

  context '#validate_deploy_job_build_number' do
    context 'when job build number is not a string' do
      it 'raises job build number missing error' do
        expect(test_error_raiser).to receive(:raise_deploy_job_build_number_missing_error)
        subject.validate_deploy_job_build_number(1)
      end
    end

    context 'when job build number is an empty string' do
      it 'raises job build number missing error' do
        expect(test_error_raiser).to receive(:raise_deploy_job_build_number_missing_error)
        subject.validate_deploy_job_build_number('')
      end
    end

    context 'when job build number is a non-empty non-numeric string' do
      it 'raises job build number missing error' do
        expect(test_error_raiser).to receive(:raise_deploy_job_build_number_missing_error)
        subject.validate_deploy_job_build_number('test')
      end
    end

    context 'when job build number is 0' do
      it 'raises job build number missing error' do
        expect(test_error_raiser).to receive(:raise_deploy_job_build_number_missing_error)
        subject.validate_deploy_job_build_number('0')
      end
    end

    context 'when job build number is non-empty numeric string' do
      it 'does not raise job build number missing error' do
        expect(test_error_raiser).not_to receive(:raise_deploy_job_build_number_missing_error)
        expect(subject.validate_deploy_job_build_number('1')).to be_nil
      end
    end
  end

end

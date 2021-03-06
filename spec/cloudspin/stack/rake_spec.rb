RSpec.describe Cloudspin::Stack::Rake do
  it 'has a version number' do
    expect(Cloudspin::Stack::Rake::VERSION).not_to be nil
  end
end

RSpec.describe Cloudspin::Stack::Rake::StackTask do
  describe 'with no parameters' do
    let (:task) { Cloudspin::Stack::Rake::StackTask.new(definition_location: './spec/dummy/') }
    it 'sets the default instance configuration files' do
      expect(task.configuration_files).to match_array(
        [
          './stack-instance-defaults.yaml',
          './stack-instance-local.yaml'
        ]
      )
    end
  end

  describe 'overriding the configuration files' do
    let (:task) {
      Cloudspin::Stack::Rake::StackTask.new(
        definition_location: './spec/dummy/',
        configuration_files: [ 'one.yaml', 'two.yaml' ]
      )
    }
    it 'has the expected file list' do
      expect(task.configuration_files).to match_array(
        [
          './stack-instance-defaults.yaml',
          './stack-instance-local.yaml',
          'one.yaml',
          'two.yaml'
        ]
      )
    end
  end

  describe 'for an environment' do
    let (:task) {
      Cloudspin::Stack::Rake::StackTask.new(
        'myenv',
        base_folder: './spec',
        definition_location: './spec/dummy/'
      )
    }
    it 'includes the environment configuration file' do
      expect(task.configuration_files).to match_array(
        [
          './spec/stack-instance-defaults.yaml',
          './spec/stack-instance-local.yaml',
          './spec/environments/stack-instance-myenv.yaml'
        ]
      )
    end
  end
end

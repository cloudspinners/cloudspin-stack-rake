
module Cloudspin
  module Stack
    module Rake

      class StackTask < ::Rake::TaskLib

        attr_reader :instance
        attr_reader :configuration_files

        def initialize(
            environment = nil,
            definition_folder: './src',
            base_folder: '.',
            configuration_files: nil
        )
          @environment = environment
          @base_folder = base_folder
          @configuration_files = configuration_files || instance_configuration_files

          @instance = Cloudspin::Stack::Instance.from_folder(
            @configuration_files,
            definition_folder: definition_folder,
            base_working_folder: "#{base_folder}/work",
            base_statefile_folder: "#{base_folder}/state"
          )
          define
        end

        def instance_configuration_files
          file_list = default_configuration_files
          if @environment
            if File.exists? environment_config_file
              file_list << environment_config_file
            else
              raise "Missing configuration file for environment #{options[:environment]} (#{environment_config_file})"
            end
          end
          file_list
        end

        def default_configuration_files
          [
            "#{@base_folder}/stack-instance-defaults.yaml",
            "#{@base_folder}/stack-instance-local.yaml"
          ]
        end

        def environment_config_file
          Pathname.new("#{@base_folder}/environments/stack-instance-#{@environment}.yaml").realdirpath.to_s
        end

        def define

          desc "Create or update stack #{@instance.id}"
          task :up do
            puts @instance.up_dry
            puts @instance.up
          end

          desc "Plan changes to stack #{@instance.id}"
          task :plan do
            puts @instance.plan_dry
            puts @instance.plan
          end

          desc "Show command line to be run for stack #{@instance.id}"
          task :dry do
            puts @instance.up_dry
          end

          desc "Destroy stack #{@instance.id}"
          task :down do
            puts @instance.down_dry
            puts @instance.down
          end

        end

      end
    end
  end
end

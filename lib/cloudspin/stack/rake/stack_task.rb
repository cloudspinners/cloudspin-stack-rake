
module Cloudspin
  module Stack
    module Rake

      class StackTask < ::Rake::TaskLib

        attr_reader :environment
        attr_reader :stack_name
        attr_reader :configuration_files

        def initialize(
            environment = nil,
            stack_name: 'instance',
            definition_location: nil,
            base_folder: '.',
            configuration_files: nil
        )
          @environment = environment
          @stack_name = stack_name
          @base_folder = base_folder
          set_configuration_files(configuration_files)

          # TODO: Pick this up from the configuration files?
          @definition_location = if definition_location
            definition_location
          else
            './src'
          end

          # @remote_zipfile = remote_zipfile
          define
        end

        def set_configuration_files(additional_configuration_files)
          @configuration_files = (the_usual_configuration_files << additional_configuration_files).flatten.compact
        end

        def the_usual_configuration_files
          file_list = default_configuration_files
          if @environment
            if File.exists? full_path_of(environment_config_file)
              file_list << environment_config_file
            else
              raise "Missing configuration file for environment #{@environment} (#{environment_config_file})"
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
          "#{@base_folder}/environments/stack-#{@stack_name}-#{@environment}.yaml"
        end

        def full_path_of(supplied_path)
          Pathname.new(supplied_path).realdirpath.to_s
        end

        def define

          desc "Create or update stack instance"
          task :up do
            puts instance.init_dry
            puts instance.up_dry
            puts instance.up
          end

          desc "Plan changes to stack instance"
          task :plan do
            puts instance.init_dry
            puts instance.plan_dry
            puts instance.plan
          end

          desc "Show command line to be run for stack instance"
          task :dry do
            puts instance.init_dry
            puts instance.up_dry
          end

          desc "Destroy stack instance"
          task :down do
            puts instance.init_dry
            puts instance.down_dry
            puts instance.down
          end

          task :refresh do
            puts instance.refresh
          end
        end

        def instance
          @instance ||= Cloudspin::Stack::Instance.from_folder(
            @configuration_files,
            stack_name: stack_name,
            definition_location: @definition_location,
            base_folder: @base_folder,
            base_working_folder: "#{@base_folder}/work"
          )
        end

      end

    end
  end
end


module Cloudspin
  module Stack
    module Rake

      class StackTask < ::Rake::TaskLib

        attr_reader :environment
        attr_reader :stack_name
        attr_reader :definition_folder
        attr_reader :configuration_files

        def initialize(
            environment = nil,
            stack_name: 'instance',
            definition_folder: nil, # Should be deprecated
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
          elsif definition_folder
            puts "'definition_folder': is deprecated for Cloudspin::Stack::Rake::StackTask - use 'definition_location' instead"
            definition_folder
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
          @instance ||= begin
            local_definition_folder = fetch_definition
            puts "Will use local stack definition files in #{local_definition_folder}"

            the_instance = Cloudspin::Stack::Instance.from_folder(
              @configuration_files,
              stack_name: stack_name,
              definition_folder: local_definition_folder,
              base_folder: @base_folder,
              base_working_folder: "#{@base_folder}/work"
            )

            if the_instance.configuration.has_remote_state_configuration?
              add_terraform_backend_source(local_definition_folder)
            end

            the_instance
          end
        end

        def add_terraform_backend_source(terraform_source_folder)
          puts "Creating file #{terraform_source_folder}/_cloudspin_created_backend.tf"
          File.open("#{terraform_source_folder}/_cloudspin_created_backend.tf", 'w') { |backend_file|
            backend_file.write(<<~TF_BACKEND_SOURCE
              terraform {
                backend "s3" {}
              }
            TF_BACKEND_SOURCE
            )
          }
        end

      end

    end
  end
end

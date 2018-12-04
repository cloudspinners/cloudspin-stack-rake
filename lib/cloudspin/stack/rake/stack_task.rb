
module Cloudspin
  module Stack
    module Rake

      class StackTask < ::Rake::TaskLib

        attr_reader :environment
        attr_reader :configuration_files

        def initialize(
            environment = nil,
            definition_location: nil,
            base_folder: '.',
            configuration_files: nil
        )
          @environment = environment
          @base_folder = base_folder
          set_configuration_files(configuration_files)

          @definition_location = definition_location
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
          "#{@base_folder}/environments/stack-instance-#{@environment}.yaml"
        end

        def full_path_of(supplied_path)
          Pathname.new(supplied_path).realdirpath.to_s
        end

        def define

          desc "Create or update stack instance"
          task :up do
            puts terraform_runner.init_dry
            puts terraform_runner.up_dry
            instance.prepare
            puts terraform_runner.up
          end

          desc "Plan changes to stack instance"
          task :plan do
            puts terraform_runner.init_dry
            puts terraform_runner.plan_dry
            instance.prepare
            puts terraform_runner.plan
          end

          desc "Show command line to be run for stack instance"
          task :dry do
            puts terraform_runner.init_dry
            puts terraform_runner.up_dry
          end

          desc "Destroy stack instance"
          task :down do
            puts terraform_runner.init_dry
            puts terraform_runner.down_dry
            instance.prepare
            puts terraform_runner.down
          end

          task :refresh do
            instance.prepare
            puts terraform_runner.refresh
          end
        end

        def instance
          @instance ||= Cloudspin::Stack::Instance.from_folder(
            @configuration_files,
            definition_location: @definition_location,
            base_folder: @base_folder,
            base_working_folder: "#{@base_folder}/work"
          )
        end

        def terraform_runner
          @terraform_runner ||= Cloudspin::Stack::Terraform.new(
            working_folder: instance.working_folder,
            terraform_variables: instance.terraform_variables,
            terraform_init_arguments: instance.terraform_init_arguments,
            terraform_command_arguments: instance.terraform_command_arguments
          )
        end

      end

    end
  end
end

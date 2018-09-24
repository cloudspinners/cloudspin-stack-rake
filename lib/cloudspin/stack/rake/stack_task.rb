
module Cloudspin
  module Stack
    module Rake

      class StackTask < ::Rake::TaskLib

        attr_reader :instance
        attr_reader :environment
        attr_reader :role
        attr_reader :configuration_files

        def initialize(
            environment = nil,
            role: 'instance',
            definition_folder: './src',
            base_folder: '.',
            configuration_files: nil
        )
          @environment = environment
          @role = role
          @base_folder = base_folder
          @configuration_files = configuration_files || the_usual_configuration_files

          @instance = Cloudspin::Stack::Instance.from_folder(
            @configuration_files,
            definition_folder: definition_folder,
            base_folder: @base_folder,
            base_working_folder: "#{@base_folder}/work"
          )
          define
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
            "#{@base_folder}/stack-#{@role}-defaults.yaml",
            "#{@base_folder}/stack-#{@role}-local.yaml"
          ]
        end

        def environment_config_file
          "#{@base_folder}/environments/stack-#{@role}-#{@environment}.yaml"
        end

        def full_path_of(supplied_path)
          Pathname.new(supplied_path).realdirpath.to_s
        end

        def define

          desc "Create or update stack #{@instance.id}"
          task :up do
            puts @instance.init_dry
            puts @instance.up_dry
            puts @instance.up
          end

          desc "Plan changes to stack #{@instance.id}"
          task :plan do
            puts @instance.init_dry
            puts @instance.plan_dry
            puts @instance.plan
          end

          desc "Show command line to be run for stack #{@instance.id}"
          task :dry do
            puts @instance.init_dry
            puts @instance.up_dry
          end

          desc "Destroy stack #{@instance.id}"
          task :down do
            puts @instance.init_dry
            puts @instance.down_dry
            puts @instance.down
          end

        end

      end
    end
  end
end

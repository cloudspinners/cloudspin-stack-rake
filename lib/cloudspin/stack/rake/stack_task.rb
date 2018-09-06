
module Cloudspin
  module Stack
    module Rake

      class StackTask < ::Rake::TaskLib

        attr_reader :id
        attr_reader :instance
        attr_reader :definition_folder
        attr_reader :instance_folder

        def initialize(id:, definition_folder: './src', instance_folder: '.')
          @instance = Cloudspin::Stack::Instance.from_definition_folder(
            id: id,
            definition_folder: definition_folder,
            instance_folder: instance_folder
          )
          @instance.add_config_from_yaml("#{instance_folder}/spin-default.yaml")
          @instance.add_config_from_yaml("#{instance_folder}/stack-instance-default.yaml")
          @instance.add_config_from_yaml("#{instance_folder}/stack-instance-defaults.yaml")
          @instance.add_config_from_yaml("#{instance_folder}/spin-local.yaml")
          @instance.add_config_from_yaml("#{instance_folder}/stack-instance-local.yaml")
          @instance.add_parameter_values({ :instance_identifier => id })

          define
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

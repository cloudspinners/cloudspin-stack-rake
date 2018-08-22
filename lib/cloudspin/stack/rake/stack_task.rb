
module Cloudspin
  module Stack
    module Rake

      class StackTask < ::Rake::TaskLib

        attr_reader :id
        attr_reader :definition_folder
        attr_reader :instance_folder

        def initialize(id:, definition_folder: './src', instance_folder: '.')
          @stack_instance = Cloudspin::Stack::Instance.from_definition_folder(
            id: id,
            definition_folder: definition_folder,
            instance_folder: instance_folder
          )
          @stack_instance.add_config_from_yaml("#{instance_folder}/spin-default.yaml")
          @stack_instance.add_config_from_yaml("#{instance_folder}/spin-local.yaml")

          define
        end

        def define

          desc "Create or update stack #{@stack_instance.id}"
          task :up do
            puts @stack_instance.up_dry
            puts @stack_instance.up
          end

          desc "Plan changes to stack #{@stack_instance.id}"
          task :plan do
            puts @stack_instance.plan_dry
            puts @stack_instance.plan
          end

          desc "Show command line to be run for stack #{@stack_instance.id}"
          task :dry do
            puts @stack_instance.up_dry
          end

          desc "Destroy stack #{@stack_instance.id}"
          task :down do
            puts @stack_instance.down_dry
            puts @stack_instance.down
          end

        end

      end
    end
  end
end

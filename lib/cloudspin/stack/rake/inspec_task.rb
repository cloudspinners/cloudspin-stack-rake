module Cloudspin
  module Stack
    module Rake

      class InspecTask < ::Rake::TaskLib

        attr_reader :stack_instance_id
        attr_reader :inspec_folder
        attr_reader :inspec_target
        attr_reader :work_folder

        def initialize(stack_instance:,
                       inspec_folder: './inspec',
                       work_folder: nil,
                       inspec_target: nil,
                       inspec_parameters: [])
          @stack_instance = stack_instance
          @stack_instance_id = stack_instance.id
          @inspec_target = inspec_target
          @inspec_parameters = inspec_parameters

          @work_folder = work_folder || @stack_instance.working_folder
          @inspec_folder = inspec_folder
          if Dir.exists?(inspec_folder)
            define
          else
            puts "No directory found: #{inspec_folder}"
          end
        end

        def define
          desc 'Run inspec tests'
          task :inspec do |t, args|
            # create_inspec_attributes.call(args)
            run_inspec_profile
          end
        end

        def run_inspec_profile
          puts "Run inspec"
          inspec_profiles_in(@inspec_folder).each { |inspec_profile_subfolder|
            cmd = inspec_command(inspec_profile_subfolder)
            puts cmd
            return if system(cmd)
            $stderr.puts "#{cmd} failed"
            exit $?.exitstatus || 1
          }
        end

        def inspec_command(inspec_profile_subfolder)
          command_parts = [
            'inspec',
            'exec',
            "#{@inspec_folder}/#{inspec_profile_subfolder}",
            '--reporter',
            "json-rspec:#{inspec_profile_results_file(inspec_profile_name(inspec_profile_subfolder))}",
            'cli']

          command_parts << ['-t', inspec_target] if inspec_target
          command_parts.join(' ')
        end

        def inspec_profile_results_file(profile_name)
          "#{work_folder}/inspec/results-for-stack-#{stack_instance_id}-profile-#{profile_name}.json"
        end

        def inspec_profile_name(subfolder_name)
          profile_spec = YAML.load_file("#{@inspec_folder}/#{subfolder_name}/inspec.yml") || {}
          profile_spec['name'] || 'default'
        end

        def inspec_profiles_in(folder)
          Dir.entries(folder).select { |possible_profile|
            possible_profile != '..' &&
              File.exists?("#{folder}/#{possible_profile}/inspec.yml")
          }
        end

      end
    end
  end
end

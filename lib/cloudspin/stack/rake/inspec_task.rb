module Cloudspin
  module Stack
    module Rake

      class InspecTask < ::Rake::TaskLib

        attr_reader :stack_instance_id
        attr_reader :work_folder
        attr_reader :inspec_folder
        attr_reader :inspec_target
        attr_reader :inspec_parameters

        def initialize(stack_instance:,
                       inspec_folder: './test/inspec',
                       work_folder: nil,
                       inspec_target: nil,
                       inspec_parameters: {})
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
            build_attributes_file
            run_inspec_profile
          end
        end

        def build_attributes_file
          ensure_path(inspec_attributes_file)
          File.open(inspec_attributes_file, 'w') {|f|
            f.write(inspec_parameters.merge(
              { 'stack_instance_id' => stack_instance_id }
            ).to_yaml)
          }
        end

        def inspec_attributes_file
          "#{work_folder}/inspec/attributes-for-stack-#{stack_instance_id}.yml"
        end

        def ensure_path(file_path)
          mkpath(File.dirname(file_path))
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
            '--attrs',
            inspec_attributes_file,
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

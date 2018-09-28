
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
          @configuration_files = configuration_files || the_usual_configuration_files

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

        def instance
          @instance ||= begin
            local_definition_folder = fetch_definition
            puts "Will use local stack definition files in #{local_definition_folder}"
            Cloudspin::Stack::Instance.from_folder(
              @configuration_files,
              stack_name: stack_name,
              definition_folder: local_definition_folder,
              base_folder: @base_folder,
              base_working_folder: "#{@base_folder}/work"
            )
          end
        end

        def fetch_definition
          if /^http.*\.zip$/.match @definition_location
            puts "Downloading stack definition source from a remote zipfile"
            fetch_definition_zipfile
          elsif /^[\.\/]/.match @definition_location
            puts "Using local stack definition source"
            @definition_location
          else
            raise UnsupportedStackDefinitionLocationError, @definition_location
          end
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
            "#{@base_folder}/stack-#{@stack_name}-defaults.yaml",
            "#{@base_folder}/stack-#{@stack_name}-local.yaml"
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
        end

        # TODO: This stuff belongs in a core class, so the CLI and other stuff can use it, too.

        def fetch_definition_zipfile
          unpack(download_artefact(@definition_location), '.cloudspin/definitions')
        end

        def download_artefact(artefact_url)
          download_dir = Dir.mktmpdir(['cloudspin-', '-download'])
          zipfile = "#{download_dir}/undetermined-spin-stack-artefact.zip"
          puts "Downloading artefact from #{artefact_url} to #{zipfile}"
          File.open(zipfile, 'wb') do |saved_file|
            open(artefact_url, 'rb') do |read_file|
              saved_file.write(read_file.read)
            end
          end
          zipfile
        end

        def unpack(zipfile, where_to_put_it)
          folder_name = path_of_source_in(zipfile)
          puts "Unzipping #{zipfile} to #{where_to_put_it}"
          Zip::File.open(zipfile) { |zip_file|
            zip_file.each { |f|
              puts "-> #{f.name}"
              f_path = File.join(where_to_put_it, f.name)
              FileUtils.mkdir_p(File.dirname(f_path))
              zip_file.extract(f, f_path) unless File.exist?(f_path)
            }
          }
          puts "Definition unpacked to #{where_to_put_it}/#{folder_name}"
          "#{where_to_put_it}/#{folder_name}"
        end

        def path_of_source_in(zipfile_path)
          File.dirname(path_of_configuration_file_in(zipfile_path))
        end

        def path_of_configuration_file_in(zipfile_path)
          zipfile = Zip::File.open(zipfile_path)
          begin
            zipfile.entries.select { |entry|
              /\/stack-definition.yaml$/.match entry.name
            }.first.name
          ensure
            zipfile.close
          end
        end

      end

      class UnsupportedStackDefinitionLocationError < StandardError; end

    end
  end
end

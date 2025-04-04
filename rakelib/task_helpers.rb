# frozen_string_literal: true

module ReactOnRails
  module TaskHelpers
    # Returns the root folder of the react_on_rails gem
    def gem_root
      File.expand_path("..", __dir__)
    end

    # Returns the folder where examples are located
    def examples_dir
      File.join(gem_root, "gen-examples", "examples")
    end

    def dummy_app_dir
      File.join(gem_root, "spec/dummy")
    end

    # Executes a string or an array of strings in a shell in the given directory in an unbundled environment
    def sh_in_dir(dir, *shell_commands)
      shell_commands.flatten.each { |shell_command| sh %(cd #{dir} && #{shell_command.strip}) }
    end

    # Executes a string or an array of strings in a shell in the given directory
    def unbundled_sh_in_dir(dir, *shell_commands)
      Dir.chdir(dir) do
        # Without `with_unbundled_env`, running bundle in the child directories won't correctly
        # update the Gemfile.lock
        Bundler.with_unbundled_env do
          shell_commands.flatten.each do |shell_command|
            sh(shell_command.strip)
          end
        end
      end
    end

    def bundle_install_in(dir)
      unbundled_sh_in_dir(dir, "bundle install")
    end

    def bundle_install_in_no_turbolinks(dir)
      sh_in_dir(dir, "DISABLE_TURBOLINKS=TRUE bundle install")
    end

    # Runs bundle exec using that directory's Gemfile
    def bundle_exec(dir: nil, args: nil, env_vars: "")
      sh_in_dir(dir, "#{env_vars} bundle exec #{args}")
    end

    def generators_source_dir
      File.join(gem_root, "lib/generators/react_on_rails")
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), new_hash|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = value.is_a?(Hash) ? symbolize_keys(value) : value
        new_hash[new_key] = new_value
      end
    end
  end
end

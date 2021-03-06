require 'pathname'
require 'yaml'

module Ufo
  module Core
    extend Memoist

    def check_task_definition!(task_definition)
      task_definition_path = "#{Ufo.root}/.ufo/output/#{task_definition}.json"
      unless File.exist?(task_definition_path)
        puts "ERROR: Unable to find the task definition at #{task_definition_path}.".colorize(:red)
        puts "Are you sure you have defined it in ufo/template_definitions.rb and it has been generated correctly in .ufo/output?".colorize(:red)
        puts "If you are calling `ufo deploy` directly, you might want to generate the task definition first with `ufo tasks build`."
        exit
      end
    end

    def root
      path = ENV['UFO_ROOT'] || '.'
      Pathname.new(path)
    end

    def env
      ufo_env = env_from_profile(ENV['AWS_PROFILE']) || 'development'
      ufo_env = ENV['UFO_ENV'] if ENV['UFO_ENV'] # highest precedence
      ufo_env
    end
    memoize :env

    def env_extra
      env_extra = Current.env_extra
      env_extra = ENV['UFO_ENV_EXTRA'] if ENV['UFO_ENV_EXTRA'] # highest precedence
      return if env_extra&.empty?
      env_extra
    end
    memoize :env_extra

    def pretty_service_name(service)
      [service, Ufo.env_extra].reject {|x| x==''}.compact.join('-')
    end

    def settings
      Setting.new.data
    end
    memoize :settings

    def cfn_profile
      settings[:cfn_profile] || "default"
    end

    def check_ufo_project!
      check_path = "#{Ufo.root}/.ufo/settings.yml"
      unless File.exist?(check_path)
        puts "ERROR: No settings file at #{check_path}.  Are you sure you are in a project with ufo setup?".colorize(:red)
        puts "Current directory: #{Dir.pwd}"
        puts "If you want to set up ufo for this prjoect, please create a settings file via: ufo init"
        exit 1 unless ENV['TEST']
      end
    end

    private
    # Do not use the Setting class to load the profile because it can cause an
    # infinite loop then if we decide to use Ufo.env from within settings class.
    def env_from_profile(aws_profile)
      data = YAML.load_file("#{Ufo.root}/.ufo/settings.yml")
      env = data.find do |_env, setting|
        setting ||= {}
        profiles = setting['aws_profiles']
        profiles && profiles.include?(aws_profile)
      end
      env.first if env
    end
  end
end

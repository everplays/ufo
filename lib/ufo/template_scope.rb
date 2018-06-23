module Ufo
  class TemplateScope
    extend Memoist

    attr_reader :helper
    attr_reader :task_definition_name
    def initialize(helper=nil, task_definition_name=nil)
      @helper = helper
      @task_definition_name = task_definition_name # only available from task_definition
        # not available from params
      load_variables_file("base")
      load_variables_file(Ufo.env)
    end

    # Load the variables defined in ufo/variables/* to make available in the
    # template blocks in ufo/templates/*.
    #
    # Example:
    #
    #   `ufo/variables/base.rb`:
    #     @name = "docker-process-name"
    #     @image = "docker-image-name"
    #
    #   `ufo/templates/main.json.erb`:
    #   {
    #     "containerDefinitions": [
    #       {
    #          "name": "<%= @name %>",
    #          "image": "<%= @image %>",
    #      ....
    #   }
    #
    # NOTE: Only able to make instance variables avaialble with instance_eval
    #   Wasnt able to make local variables available.
    def load_variables_file(filename)
      path = "#{Ufo.root}/.ufo/variables/#{filename}.rb"
      instance_eval(IO.read(path), path) if File.exist?(path)
    end

    # Add additional instance variables to template_scope
    def assign_instance_variables(vars)
      vars.each do |k,v|
        instance_variable_set("@#{k}".to_sym, v)
      end
    end

    def network
      n = Ufo::Setting::Network.new(settings[:network_profile]).data
      # pp n
      n
    end
    memoize :network

    def settings
      Ufo.settings
    end

    def custom_properties(resource)
      resource = resource.to_s.underscore
      properties = network[resource.to_sym]
      return unless properties

      # camelize keys
      properties = properties.deep_transform_keys { |key| key.to_s.camelize }
      yaml = YAML.dump(properties)
      # add spaces in front on each line
      yaml.split("\n")[1..-1].map do |line|
        "      #{line}"
      end.join("\n") + "\n"
    end

    def default_target_group_protocol
      default_elb_protocol
    end

    def default_elb_protocol
      @elb_type == "application" ? "HTTP" : "TCP"
    end

    def static_name?
      # env variable takes highest precedence
      if ENV["STATIC_NAME"]
        ENV["STATIC_NAME"] != "0"
      else
        settings[:static_name]
      end
    end
  end
end

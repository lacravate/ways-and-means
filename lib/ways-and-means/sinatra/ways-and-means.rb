# encoding: utf-8

require 'sinatra/base'

require 'pathstring'

module Sinatra

  module WaysAndMeans

    # reserved configuration keys
    # i allow people to be less funky than i am
    # with key names, hence 'routes' and 'config'
    WAYS_KEYS = %w|ways routes|.freeze
    MEANS_KEYS = %w|means config|.freeze

    # HTTP verbs list
    VERBS = %w|get post patch put delete head options|.freeze

    attr_accessor :config
    attr_reader :ways

    def ways_and_means!(*ways_and_means)
      ways_and_means << { file: true } if ways_and_means.empty?

      ways_and_means.each do |w_m|
        @config = if w_m[:file] || w_m['file']
          config_from_file w_m[:file] || w_m['file']
        else
          w_m
        end


        # the verb
        # the endpoint to string prefixed by '/'
        # the callback
        #
        # get '/plop' do
        #   callback
        # end
        ways! do |endpoint, dispatch|
          # if ever you wanna do something
          # with dispatch info' set right
          yield endpoint, dispatch if block_given?
          (@ways ||= []) << [endpoint, dispatch]

          renderer_callback dispatch if dispatch[:renderer]

          send dispatch[:verb], "/#{endpoint}" do
            # before hooks before
            ['before_anyway', "before_#{dispatch[:to]}"].each { |hook| respond_to?(hook, true) && send(hook) }
            send(dispatch[:to]).tap do
              # after hooks in a tap, because i like tap
              # Mmmh ? And yes, also because i need to maintain the return of the
              # route call back as the return value of the route
              ["after_#{dispatch[:to]}", 'after_anyway'].each { |hook| respond_to?(hook, true) && send(hook) }
            end
          end
        end

        make_way! if @config['make_way'] || @config[:make_way]

        # settings
        means!
      end
    end

    def make_way!
      ways.each do |endpoint, dispatch|
        endpoint = rationalize endpoint
        define_method "#{dispatch[:to]}_root".to_sym do
          instance_variable_get("@#{dispatch[:to]}_root") || instance_variable_set(
            "@#{dispatch[:to]}_root",
            Pathstring.new("/#{endpoint}")
          )
        end

        define_method "#{dispatch[:to]}_url".to_sym do |*args|
          send("#{dispatch[:to]}_root").join(*args)
        end
      end
    end

    private

    def defaults
      config['defaults'] || config[:defaults] || {}
    end

    def ways!
      ways_config.each do |endpoint, dispatch|
        # home: { get: { to: 'home', other_params: "plop" }, patch: { to: 'patch_home', other_params: "plip" } }
        # get '/home' do
        #   home
        # end
        #
        # patch '/home' do
        #   patch_home
        # end
        if dispatch.respond_to?(:any?) && dispatch.any? { |k, v| VERBS.include? k.to_s }
          dispatch.each do |k, v|
            yield endpoint, defaults.merge(verb: k.to_s, to: rationalize("#{k}_#{endpoint}")).merge(v || {})
          end

        # index: { to: 'show_index', other_params: "plop" }
        # get '/index' do  ## no verb specified, defaulted to 'get'
        #   show_index
        # end
        elsif dispatch.is_a?(Hash)
          yield endpoint, defaults.merge(verb: 'get', to: rationalize(endpoint)).merge(dispatch)

        # show: nil
        # get '/show' do  ## no verb specified, defaulted to 'get'
        #   show
        # end
        #
        # 'show/:person_id': "show_person"
        # get '/show/:person_id' do  ## no verb specified, defaulted to 'get'
        #   show_person
        # end
        else
          yield endpoint, defaults.merge(verb: 'get', to: (dispatch || rationalize(endpoint)))
        end
      end
    end

    def means!
      # set key / values in App.settings
      means_config.each do |mean, it|
        set mean, it
      end
    end

    def renderer_callback(dispatch)
      define_method dispatch[:to].to_sym do
        send dispatch[:renderer],
             dispatch[:to].to_sym,
             respond_to?(:renderer_options, true) ? send(:renderer_options) : {},
             respond_to?(:renderer_locals, true)  ? send(:renderer_locals)  : {}
      end
    end

    def ways_config
      # hash.slice, i miss you...
      # at least this is safe and very explicit
      config['ways'] || config[:ways] || config['routes'] || config[:routes] || {}

      # while this is not
      # WAYS_KEYS.inject({}) { |w, k| w.merge!(config[k] || config[k.to_sym] || {}) }

      # and this is ruby-coated Perl
      # WAYS_KEYS.map { |k| [k, k.to_sym] }.flatten.map { |k| config[k] }.compact.first
    end

    def means_config
      # hash.slice, i miss you...
      # at least this is safe and very explicit
      config['means'] || config[:means] || config['config'] || config[:config] || {}
    end

    def rationalize(endpoint)
      # rationalized... but not too clever though.
      endpoint.to_s.gsub('/', '_').gsub(/[^A-Za-z0-9_]/, '').gsub('_id', '').gsub(/_$/, '')
    end

    def config_from_file(file)
      file = ['config', 'ways-and-means.yml'] if file == true

      YAML.load Pathstring.join(*file).read rescue {}
    end

  end

end

# encoding: utf-8

require 'sinatra/base'

module Sinatra

  module WaysAndMeans

    # reserved configuration keys
    # i allow people to be less funky than i am
    # with key names, hence 'routes' and 'config'
    WAYS_KEYS = %w|ways routes|.freeze
    MEANS_KEYS = %w|means config|.freeze

    # HTTP verbs list
    VERBS = %w|get post patch put delete head options|.freeze

    def ways_and_means!(ways_and_means=nil)
      # Pfff'... Should probably be more tyrannical here...
      # if you registered, you should know what you're doing, right ?
      return unless @config = ways_and_means || config

      # the verb
      # the endpoint to string prefixed by '/'
      # the callback
      #
      # get '/plop' do
      #   callback
      # end
      ways do |endpoint, dispatch|
        # if ever you wanna do something
        # with dispatch info' set right
        yield endpoint, dispatch if block_given?

        send dispatch[:verb], "/#{endpoint}" do
          send dispatch[:to]
        end
      end

      # settings
      means
    end

    private

    def ways
      ways_config.each do |endpoint, dispatch|
        # home: { get: { to: 'home', other_params: "plop" }, patch: { to: 'patch_home', other_params: "plip" } }
        # get '/home' do
        #   home
        # end
        #
        # patch '/home' do
        #   patch_home
        # end
        if dispatch.is_a?(Hash) && dispatch.keys.any? { |k| VERBS.include? k.to_s }
          dispatch.each do |k, v|
            yield endpoint, v.merge(verb: k)
          end

        # index: { to: 'show_index', other_params: "plop" }
        # get '/index' do  ## no verb specified, defaulted to 'get'
        #   show_index
        # end
        elsif dispatch.is_a?(Hash)
          yield endpoint, { verb: 'get' }.merge!(dispatch)

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
          yield endpoint, { verb: 'get', to: (dispatch || endpoint) }
        end
      end
    end

    def means
      # set key / values in App.settings
      means_config.each do |mean, it|
        set mean, it
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

    # Well... What can i say now ...? Oh, i know : too many parentheses !
    def config
      @config ||= YAML.load(open(File.join('config', 'ways-and-means.yml'))) rescue nil
    end

  end

  register WaysAndMeans

end

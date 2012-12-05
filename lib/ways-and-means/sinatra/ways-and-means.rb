# encoding: utf-8

require 'sinatra/base'
require 'yaml'

module Sinatra

  module WaysAndMeans

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
        if dispatch.is_a?(Hash) && dispatch.keys.any? { |k| VERBS.include? k }
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

    def ways_config
      # at least this is safe and very explicit
      # hash.slice, i miss you...
      config['ways'] || config[:ways] || config['routes'] || config[:routes] || {}

      # while this is not
      # WAYS_KEYS.inject({}) { |w, k| w.merge!(config[k] || config[k.to_sym] || {}) }

      # and this is ruby-coated Perl
      # WAYS_KEYS.map { |k| [k, k.to_sym] }.flatten.map { |k| config[k] }.compact.first
    end
 
    def means
      # set key / values in App.settings
      means_config do |mean, it|
        set mean, it
      end
    end
 
    def means_config
      # key / values except reserved space for routes
      config.reject { |k, v| k == 'ways' || k == 'routes' }.each do |k, v|
        yield k.to_sym, v
      end
    end

    # Well... What can i say now ? Oh, too many parentheses !
    def config
      @config ||= YAML.load(open(File.join('config', 'ways-and-means.yml'))) rescue nil
    end

  end

  register WaysAndMeans

end

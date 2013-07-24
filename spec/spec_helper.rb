# encoding: utf-8

require 'rack/test'

require File.expand_path('../../lib/ways-and-means.rb', __FILE__)

RSpec.configure do |config|
  # --init
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

#

# Blue eyes
require 'sinatra/base'

# The app'
class WaysAndMeansTester < Sinatra::Base

  register Sinatra::WaysAndMeans

  class << self

    attr_accessor :conf, :ways

    def setup
      # call routes setup and define target callback
      # on the fly, for now and any newcomer in the spec's
      ways_and_means! conf do |endpoint, dispatch|
        unless %w|where post_there|.include? dispatch[:to].to_s
          define_method dispatch[:to].to_sym do
            dispatch[:to].to_s.dup
          end
        end
      end
    end
  end

  def before_anyway
    self.class.set :hook, "hook"
  end

  def after_show_index
    self.class.set :hook, "after_show_index"
  end

  def before_here
    self.class.set :hook, "before_here"
  end

  def primary_renderer(data, options, locals)
    data.to_s
  end

  def my_renderer(data, options, locals)
    "i rendered #{data}#{locals[:with_args]}"
  end

  def renderer_locals
    params[:locals] ? { with_args: " with args" } : {}
  end

end

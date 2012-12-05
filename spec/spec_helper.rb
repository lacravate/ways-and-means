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

# Routes (and a little bit of conf') in a hash
conf = {
  # conf
  location: 'plop',

  # routes
  ways: {
    # /here => here
    here: nil,

    there: {
      # post /there => post_there
      post: { to: 'post_there' },
      # patch /there => patch_there
      patch: { to: 'patch_there' }
    },

    # get /index => show_indew
    # get is implicit
    index: { to: 'show_index' },

    # post /list => post_list
    list: { to: 'post_list', verb: 'post' },

    # get /show/42 => qhow_person
    'show/:person_id' => "show_person"
  }
}

# 'got to implement a way to specify the config file path
# because it's useful and to put this away from the lib's
# root directory

# Hash in a file
FileUtils.mkdir_p 'config'
File.open(File.join('config', 'ways-and-means.yml'), 'w') { |f| f.write YAML.dump(conf) }

# Blue eyes
require 'sinatra/base'

# The app'
class WaysAndMeansTester < Sinatra::Base
YAML.load(open(File.join('config', 'ways-and-means.yml')))
  # our own teeny tiny snippet
  register Sinatra::WaysAndMeans
  
  # call routes setup and define target callback
  # on the fly, for now and any newcomer in the spec's
  ways_and_means! do |endpoint, dispatch|
    define_method dispatch[:to].to_sym do
      dispatch[:to].to_s.dup
    end
  end

end

# cleaning
FileUtils.rm_f File.join('config', 'ways-and-means.yml')

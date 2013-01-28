# Ways-And-Means

`ways-and-means` allows to pass configuration data to a Sintra app', and use
a subset of this data to setup the application routes. Also, there is a very
simple and starightforward hooks mechanism.

## Installation

Ruby 1.9.2 is required.

Install it with rubygems:

    gem install ways-and-means

With bundler, add it to your `Gemfile`:

``` ruby
gem "ways-and-means"
```

## Use

The usual with a Sinatra contrib' :

``` ruby

require 'sinatra/base'
require 'ways-and-means'

class MyApp < Sinatra::Base

  register Sinatra::WaysAndMeans

  ways_and_means!

end
```

### Ways

In this case, routes will be read from `config/ways-and-means.yml`. But they
also can be specified by passing a hash at `ways_and_means!` call, like this :

``` ruby
ways_and_means! ways: {
  here: nil,                     # GET /here => here equivalent to here: 'here'.
                                 # Endpoint 'here' is "rationalized" from route
                                 # the way it is explained below
  there: {
    post: { to: 'post_there' },  # POST /there => post_there
    patch: { to: 'patch_there' } # PATCH /there => patch_there
  },

  index: { to: 'show_index' },   # GET /index => show_index, GET is implicit
  list: {                        # POST /list => post_list
    to: 'post_list',
    verb: 'post'
  },
  'stuff/:id' => "get_stuff"     # GET /stuff/42 => get_stuff
}
```

This will be equivalent, in a Sinatra app', to :

``` ruby
get '/here' do
  here
end

post '/there' do
  post_there
end

patch '/there' do
  patch_there
end

get '/index' do
  show_index
end

post '/list' do
  post_list
end

get '/show/:person_id' do
  show_person
end
```

For very (very very) simple routing, routes can be passed as a list,
`ways-and-means` will do its best to rationalize the endpoint and turn it into a
callback.

```ruby
ways_and_means! ways: [:here, 'get/that/?', 'show/:resource_id', 'browse/*']

```

will be (hopefully) understood as :

```ruby
get '/here' do
  here
end

get 'get/that/?' do
  get_that # '/' turned to '_', trailing '_' is discarded
end

get 'show/resource_id' do
  show_resource # '/' turned to '_', '_id' are discarded
end

get 'browse/*' do
  browse # keep only /A-Za-z0-9_/, no trailing '_'
end
```

### Means

You can also pass additionnal configuration data with the key `means`.

``` ruby
ways_and_means! ways: {
    # some key / value pairs to setup routes
  },

  means: {
    config_one: 'foo',
    config_two: 'bar',
  }
```

All the key / value pairs found in the `means` hash will be added to your
application `settings`.

### Hooks

This simple feature lets you setup `before` and `after` hooks. Sinatra already
has got `before`s and `after`s but they are filters, not hooks.

Given a route callback (say `show_index` in the routes above), user-defined
`before_anyway` and `before_show_index` (`"before_#{route_callback}"`) methods
will be executed before the route callback if defined. As well, `after_anyway`
or `after_show_index` (`"after_#{route_callback}"`) will be executed after the
route callback if defined.

## Aims

The idea is not only to save myself from some typing (even though that's an
argument).

The idea is not to issue an all-encompassing lib' that will allow to put in
conf' any route-related feature of Sinatra.

The main goal is to replace routing to where and what i think it should be
(configuration), and put away the intelligence of the app' away from a mere
unnamed block.

## Temptations

 - integrate the config file Sinatra contrib to get routes config from
 - HTTP status codes
 - additionnal params passed to the callback
 - use the WTFPL

## Laughs

That i had thinking of the addition of spec's, comments in the code and
documentation, compared to the amount of code, and the limited scope of this
snippet dignified to a library with a name. 

## Thanks

Eager and sincere thanks to all the Ruby guys and chicks for making all this so
easy to devise.

## Copyright

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.

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

If no definition has was passed, and no filename given, it will look for a
`config/ways_and_means.yml` file.

``` ruby
ways_and_means! items = {           # the assignment here is only useful to make
    file: true                      # Ruby understand the first argument is a
  },                                # hash and not a block

  { ways: { login: [:post, :put] }, # endpoint with a list of verbs
    make_way: true
  },
  { ways: ['here/*', 'there/*'],    # list of endpoints, GET is implicit
    make_way: true
  },
  { ways: ['show/*', 'admin/*'],    # list of endpoints
    defaults: { renderer: :slim },  # different defaults
    make_way: true
  },

  # explicit definitions
  {
    that: {                              # endpoint
      post: { to: 'not_not_post_that' }, # explicit definition of callbacks
      patch: { to: 'really_patch_that' } # per verb
    },
    list: {                              # single endpoint definition
      to: 'list_post',                   # with its callback
      verb: 'post'                       # and verb
    }
  }

# this would have worked with several call to `ways_and_means!` :
# ways_and_means! file: true
# ways_and_means! ways: { login: [:post, :put] },
#                 make_way: true
# and so on...

```

This will be equivalent, in a Sinatra app', to :

``` ruby
post '/login' do
  post_login # http verb prefix only when a verb directive
             # was given in the definitions
end

put '/login' do
  post_login
end

get '/here' do
  here # no word directive, plain endpoint name, no prefix
end

get '/there' do
  there
end

get '/show/*' do
  slim :show, renderer_options, renderer_locals # renderer_options and
                                                # renderer_locals are
                                                # user-defined methods
                                                # defaulting to {}
end

get '/admin/*' do
  slim :show, renderer_options, renderer_locals
end

post '/that' do
  not_not_post_that
end

patch '/that' do
  really_patch_that
end

post '/list' do
  list_post
end
```

With `file` option to point there will be definitions or configurations to be
found in a file (you can pass a filename instead of `true`).

With `renderer` option to spare you from writing stupid lines of code such as :
``` ruby
get '/that' do
  haml :that
end
```

With `make_way` option to create simple route builder helper methods :
  post_login_root # works like a pathname, hence use join
  post_login_url  # will make the join for you with the arguments list you passed

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
has got `before` and `after` but they are filters, not hooks.

Given a route callback (say `here` in the routes above), user-defined
`before_anyway` and `before_here` (`"before_#{route_callback}"`) methods
will be called before the route callback, if defined. As well, `after_anyway`
or `after_here` will be called after the
route callback if defined.

## Aims

The main goal is to replace routing to where and what i think it should be :
configuration. And put the intelligence of the app' in a neat module
(for example) defining the routes callbacks.

## Thanks

Eager and sincere thanks to all the Ruby guys and chicks for making all this so
easy to devise.

## Copyright

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.

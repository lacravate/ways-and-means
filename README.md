# Ways And Means

Ways and Means allows the setup of Sinatra routes through configuration data.

## Installation

Ruby 1.9.2 is required.

Install it with rubygems:

    gem install ways-and-means

With bundler, add it to your `Gemfile`:

``` ruby
gem "ways-and-means"
```

## Use

Somewhere in the code of the Sinatra app' :

``` ruby
require 'ways-and-means'
```

Somewhere else :

``` ruby
register Sinatra::WaysAndMeans
```

And some other place :

``` ruby
ways_and_means!
```

Routes will be read from :
``` ruby
config/ways-and-means.yml
```

``` yaml
ways:
  here:
  there:
    post:
      to: "post_there"
    patch: "api_key"
      to: "patch_there"
  index:
    to: 'show_index'
  list:
    to: 'post_list'
    verb: 'post'
  'show/:person_id': "show_person"

name: 'ways-and-means',
```

is equivalent, in a Sinatra app', to :

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

As well, because it was easy and useful, all the other keys in the config
file are considered config entries in the application settings.

You can also pass configuration to `ways-and-means` directly at its call :

``` ruby
ways_and_means! ways: {
  home: {
    put: 'it_there',
    get: 'up!'
  }
}
```


## Aims

The idea is not only to save myself from some typing (even though that's an
argument).

The idea is not to issue an all-encompassing lib' that will allow to put in
conf' any route-related feature of Sinatra. The code will evolve along with my
needs (and yours if you read this, and are polite).

The main goal is to replace routing to where and what it should be, and foster
some programming architecture : put the intelligence of the application away
from a mere unnamed block, even if the app' has only two routes.

## Temptations

  - integrate the config file Sinatra contrib to get routes config from
  - HTTP status codes
  - additionnal params passed to the callback
  - use the WTFPL


# Laughs

That i had thinking of the addition of spec's, comments in the code and
documentation, compared to the amount of code, and the limited scope of this
snippet dignified to a library with a name. 

Copyright
---------

I was tempted by the WTFPL, but i have to take time to read it.
So far see LICENSE.

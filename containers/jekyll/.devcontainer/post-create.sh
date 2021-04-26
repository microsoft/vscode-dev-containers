#!/bin/sh

# If there's a Gemfile, then run `bundle install`
# It's assumed that the Gemfile will install Jekyll too
if [ -f Gemfile ]; then
    bundle install
else
    # If there's no Gemfile, install Jekyll
    sudo gem install jekyll
fi

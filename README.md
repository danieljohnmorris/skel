# Social login boilerplate app

I needed a simple starting point app, it doesn't have a lot of bells and whistles, mostly just followed the Railscasts on Devise (user auth) and Omniauth (third party auth).

Feel free to fork this project for your own projects.


## Getting started

...


### Config

Copy config/app_config.EXAMPLE.yml to config/app_config.yml, and populate with your own third-party API keys. 

Remove services you don't need from views/authentications.html.erb

Add extra config lines for your settings and access them using APP_CONFIG[:some_setting]

## Deploy

Article on deploying rails 3 apps to Heroku cloud hosting:
http://devcenter.heroku.com/articles/rails3

Postgres is a required gem for Heroku. If you don't want pg installed locally (or in my case it errors), use this command to install bundle gems locally without it:
bundle install --without production


### Stuff used

Skull clipart from http://www.clker.com/clipart-skull-and-bones.html
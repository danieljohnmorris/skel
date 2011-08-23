# Skellington app - Simple boilerplate app with social login

I needed a simple starting point app for prototyping facebook/twitter app. It doesn't have a lot of bells and whistles, mostly just followed the Railscasts on Devise (user auth) and Omniauth (third party auth).

Feel free to fork this project for your own projects.

See a demo: http://skel.herokuapp.com/

### Config

To create a new app, simply fork this repo!

Copy config/app_config.EXAMPLE.yml to config/app_config.yml, and populate with your own third-party API keys. Also, remove app_config.yml from the .gitignore file in the project root, and check it in. You'll need it versioned when you go to deploy.

Add extra config lines to config/app_config.yml for your own settings and access them using APP_CONFIG[:some_setting]

Remove services you don't need from views/authentications.html.erb

Postgres is a required gem for Heroku (assuming you'll be deploying to heroku, at least for prototypes). If you don't want the "pg" gem installed locally (or in my case it errors), use this command to install bundle gems locally without it:
bundle install --without production

## Deploy

Article on deploying rails 3 apps to Heroku:
http://devcenter.heroku.com/articles/rails3

Something like:
1. "heroku create yourappname --stack cedar"
2. Add yourappname.herokuapp.com URL to config/app_config.yml and config/environments/production.rb
3. git push heroku master
4. heroku run rake db:migrate --trace
5. heroku open

## Stuff used

### Twitter Bootstrap (Frontend toolkit)

Go here and be amazed:
http://twitter.github.com/bootstrap/

### Devise (Rails 3 friendly user auth)

Read this:
https://github.com/plataformatec/devise

Watch this:
http://railscasts.com/episodes/209-introducing-devise

### Omniauth (Third party auth)

Read this:
https://github.com/intridea/omniauth

Watch these:
http://railscasts.com/episodes/235-omniauth-part-1
http://railscasts.com/episodes/236-omniauth-part-2

### Skull clipart

Pillaged from: 
http://www.clker.com/clipart-skull-and-bones.html

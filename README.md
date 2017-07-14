# Hubstats [![Build Status](https://travis-ci.org/sportngin/hubstats.svg?branch=master)](https://travis-ci.org/sportngin/hubstats)

Hubstats is a rails plugin which allows you to search and monitor pull requests, teams, and users made across a collection of repositories. It also gives extra statistics about users, teams, and pull requests not found on GitHub. For more information on Hubstats and the development of Hubstats, see the Coding in the Crease [Hubstats blog](http://www.codinginthecrease.com/news_article/show/545869?referrer_id) by Emma Sax. For additional information on the setup process of Hubstats, although you'll find plenty below, go to the [Hubstats wiki](https://github.com/sportngin/hubstats/wiki).

## Setup
The following setup is designed to only be used when integrating this plugin into a rails application.

 Run `rails generate hubstats:install`.
 
 Configure `octokit.yml` with your GitHub information (see below).

 Run `rake hubstats:install:migrations`.

 Run `rake hubstats:setup` to run the necessary migrations and start pulling data from GitHub.

 Add 'mount Hubstats::Engine => "/hubstats"' to your apps routes file.

## Configuration
### Authentication
Hubstats needs GitHub credentials to access your repositories, these can be setup in one of two ways:

#### GitHub API Tokens
Add your GitHub API token (called `access_token`) to `octokit.yml`.

#### Environment Variables
Hubstats can also use OAUTH access tokens stored in ENV["GITHUB_API_TOKEN"] if for some reason you don't want to store them in `octokit.yml`.

### Configuring Data to be Received from GitHub
#### Organizations to Follow
Hubstats tracks certain repositories and teams that are part of an organization. Therefore, you must whitelist the specific GitHub organization to track in `octokit.yml`. The list of organizations should look something like this:

```
org_name:
 - sportngin
 ```
 
#### Repositories to Follow
If you only want Hubstats to watch certain repositories, you can set it to watch a list of specific repositories in `octokit.yml`. Otherwise, the default will be for Hubstats to watch an entire organization's list of repositories. The list of repositories should look like either:

```
repo_list:
 - sportngin/repo_one
 - sportngin/repo_two
 - sportngin/repo_three
```

#### Teams to Follow
If you want Hubstats to watch certain teams to give back GitHub team metrics, then you must whitelist a list of teams in the `octokit.yml`. If no list of teams is added, then there will be no team metrics. The list of teams should look something like:

```
team_list:
 - Team One
 - Team Two
 - Team Three
```

Also, the GitHub API token in `octokit.yml` must be a member of all of the teams listed in order to receive webhooks and populate team data.

#### Users to Ignore
If there are specific users that should not show up on any lists or in any metrics, then they can be placed on the `ignore_users_list` part of the `octokit.yml`. This list is referenced when making the list of users in teams. The list of users to ignore should look like:

```
ignore_users_list:
 - user_login_one
 - user_login_two
 - user_login_three
```

### Webhooks
Hubstats uses GitHub webhooks to keep its data updated. It requires you to set a secret as well as an endpoint to push to.

To generate a secret run:
 ```
 ruby -rsecurerandom -e 'puts SecureRandom.hex(20)'
 ``` 
Set the endpoint to be:

 www.yourdomain.com/hubstats/handler

## Testing
All of the automated tests are written in RSpec. To run these tests, run the following commands, assuming that there are two already existent local databases titled `hubstats_development` and `hubstats_test`:
```
cd test/dummy/
rake db:test:prepare
bundle exec rspec
```
To test what Hubstats would actually look like on a web browser, we need to install the plugin into a Rails application to run. This is because Hubstats is a plugin, not an application. The `test` directory is also a dummy rails application for manually testing the UI by serving Hubstats locally. When developing and using the `test/dummy` locally, then the test will automatically sync with any updated code, so it doesn't need to be re-served when changes are made with the normal Rails application. When in the development process, one just needs to run:
```
cd test/dummy/
bundle exec rails s
```
to serve the plugin. http://guides.rubyonrails.org/plugins.html will give more information on the implementation of a Rails plugin. 

## TL:DR
  Run `rails generate hubstats:install`.
  
  Configure `octokit.yml` with your GitHub information (see above).
  
  Run `rake hubstats:install:migrations`.
  
  Run `rake hubstats:setup`.
  
  Add 'mount Hubstats::Engine => "/hubstats"' to your routes file.
  
  Read [this blog about Hubstats](http://www.codinginthecrease.com/news_article/show/545869?referrer_id).
  
  Go to the [Hubstats wiki](https://github.com/sportngin/hubstats/wiki) for additional information.

<hr>

This project rocks and uses MIT-LICENSE.

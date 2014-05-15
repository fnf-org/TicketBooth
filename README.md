# HelpingCulture

**HelpingCulture** is an application that aims to make ticket and volunteer
management for community events easier.

## Getting Started

If you want to contribute to the HelpingCulture codebase, there's a few things
you need to do in order to get started.

  * Run a Mac or Linux operating system

  * Clone this repository: `git clone git@github.com:sds/helpingculture.git`

  * Ensure Ruby 2.1.1 is installed; you can check this by running
    `ruby --version` from the command-line. The easiest way to install this
    specific version of Ruby (and to manage multiple versions of Ruby on a
    single system if you're developing other projects on different Ruby
    versions) is to use [rbenv](https://github.com/sstephenson/rbenv/).
    However, if you have a clean system and don't intend on doing anything
    except do HelpingCulture development on it, you can get away with upgrading
    your system-wide Ruby.

  * Install Bundler, which manages the gems (Ruby libraries) that
    HelpingCulture uses: `gem install bundler`

  * Install all gem dependencies using Bundler: `bundle install`

  * Install Postgres 9.1.3; you can check this by running `psql --version`

  * Create a database user for the HelpingCulture Rails application to use when
    connecting to Postgres. Connect as the `postgres` (or whatever user has
    admin privileges) user using the `psql` utility, and then run:
    `CREATE ROLE app WITH CREATEDB LOGIN PASSWORD 'dev_password';`
    The `app` and `dev_password` are up to you.

  * Copy the `config/database.yml.example` file to `config/database.yml`, and
    edit the `username` and `password` fields to match the user/password you
    chose in the previous step (you can use the defaults if you want).

  * Create the databases using the information you defined in
    `config/database.yml` by running `rake db:create`

  * Fill the database with tables by running the database migrations:
    `rake db:migrate db:test:prepare` (the `db:test:prepare` is necessary
    only if you want to run the tests)

  * Copy the `config/stripe.yml.example` file to `config/stripe.yml`. If you
    have your own Stripe account that you want to test with, use the secret
    key and public key from that account instead (but the defaults will work
    out of the box if you don't want to use your own Stripe account).

You should now be all set. Try spinning up a local development server by
running:

    bundle exec rails server

This should run an all-in-one server that you can access from your browser
at `http://localhost:3000`. It will also automatically load any changes
you make to code in the repo's `app` directory. Changes anywhere else will
require you to restart the server.

If you want to work within a Ruby console, `rails console` is incredibly
useful for playing around in the Rails environment.

## Faster Development

If you're tired of waiting for Rails to load up every time you type
`bundle exec rails server`, you should use [zeus](https://github.com/burke/zeus).
Zeus preloads Rails in a separate process so you don't have to wait for it to
load each time. To use zeus, just run:

    zeus start

to start the Zeus server and preload the Rails app. Any time you want to spin
up a server or run tests, you can then do:

    zeus server

or:

    zeus test [directory or spec file(s) to run]

respectively. See the output of `zeus start` for other commands you can run.

## Contributing

### Write helpful commit messages

When making changes to the code, ensure your commit messages are descriptive.
A good summary of git commit messages can be found
[here](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html),
but you can look at the repository history for some examples using `git log`.

### Write tests

Automated tests are your friend. See the `spec` directory for examples.
You can run the automated tests by running `bundle exec rspec spec`
(where `spec` is the directory of specs, or individual list of specs, that you
want to run) in the repository.

## Deploying

If your SSH public key has been added to the production server's list of
authorized keys, you can deploy the latest version of the code to the
production site using `cap deploy`. Before you do this, remember to push
your local changes to the `origin` repository with `git push origin master`,
as the deploy process can only deploy code from that canonical source.

If you don't have permission to deploy, you can submit a pull request to
the repository and someone will review your code and merge it if it's good
to go.
See [Using Pull Requests](https://help.github.com/articles/using-pull-requests)
for more information on this process if you are not familiar.

## Help

If you need any more help, don't be afraid to ask!

# Cloudwatch

This is the Cloudwatch web application. Hang on tight.

## Getting Started

If you want to contribute to the Cloudwatch codebase, there's a few things you
need to do in order to get started.

  * Run a Mac or Linux operating system

  * Clone this repository: `git clone git@github.com:sds/cloudwatch.git`

  * Ensure Ruby 1.9.3p327 is installed; you can check this by running
    `ruby --version` from the command-line. The easiest way to install this
    specific version of Ruby (and to manage multiple versions of Ruby on a
    single system if you're developing other projects on different Ruby
    versions) is to use [rbenv](https://github.com/sstephenson/rbenv/).
    However, if you have a clean system and don't intend on doing anything
    except do Cloudwatch development on it, you can get away with upgrading
    your system-wide Ruby to 1.9.3p327.

  * Install Bundler, which manages the gems (Ruby libraries) that Cloudwatch
    uses: `gem install bundler`

  * Install all gem dependencies using Bundler: `bundle install`

  * Install Postgres 9.1.3; you can check this by running `psql --version`

  * Create a database user for the Cloudwatch Rails application to use when
    connecting to Postgres. Connect as the `postgres` admin user using the
    `psql` utility, and then run:
    `CREATE ROLE app WITH CREATEDB LOGIN PASSWORD 'dev_password';`
    The `app` and `dev_password` are up to you.

  * Copy the `config/database.yml.example` file to `config/database.yml`, and
    edit the `username` and `password` fields to match the user/password you
    chose in the previous step.

  * Create the databases using the information you defined in
    `config/database.yml` by running `rake db:create:all`

  * Fill the database with tables by running the database migrations:
    `rake db:migrate`.

You should now be all set. Try spinning up a local development server by
running:

    rails server

This should run an all-in-one server that you can access from your browser
at `http://localhost:3000`. It will also automatically load any changes
you make to code in the repo's `app` directory. Changes anywhere else will
require you to restart the server.

If you want to work within a Ruby console, `rails console` is incredibly
useful for playing around in the Rails environment.

## Contributing

### Write helpful commit messages

When making changes to the code, ensure your commit messages are descriptive.
A good summary of git commit messages can be found
[here](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html),
but you can look at the repository history for some examples using `git log`.

### Write tests

Automated tests are your friend. See the `spec` directory for examples.
You can run the automated tests by running `rspec` in the repostory.

## Deploying

If your SSH public key has been added to the production server's list of
authorized keys, you can deploy the latest version of the code to the
production site using `cap deploy`. Before you do this, remember to push
your local changes to the `origin` repository, as the deploy process can
only deploy code from that canonical source.

If you don't have permission to deploy, you can submit a pull request to
the repository and someone will review your code and merge it if it's good
to go.
See [Using Pull Requests](https://help.github.com/articles/using-pull-requests)
for more information on this process if you are not familiar.

## Help

If you need any more help, don't be afraid to ask!

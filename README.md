# Dockable

This is a gem that helps us with getting a common setup for our Ruby apps.

Features:

* Load environment variables from S3.
* Execute commands from a Procfile.

At Teachable, this gem is preinstalled on our Docker base images that have Ruby.

## Usage


Dockable is a prefix to commands just like "bundle exec" or "time".

Say you have the following `Procfile`:

``` yaml
web: bundle exec puma -c config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rake release
```

You can run puma like this:

```
$ dockable web
```

### Loading environment variables from S3

If you've specified the `DOCKABLE_ENV_BUCKET_NAME` and `DOCKABLE_ENV_KEY_NAME` variables, it will try to download an environment file from that location.

That environment file is a yaml file, like this:

``` yaml
RAILS_ENV: production
DATABASE_URL: postgres://...
SECRET_KEY_BASE: deadbeef1234...
```

The reason we do it this way is so we don't have to configure so many environment variables when booting a Docker image.

The values of `DOCKABLE_ENV_BUCKET_NAME` would be something like `"teachable-secrets"` and the value of `DOCKABLE_ENV_KEY_NAME` would be `"name-of-app/production.yml"`.

Make sure the bucket you store these environment variables in is private, but readable for your docker image, and uses encryption.

You can use dockable as an `ENTRYPOINT` option in your Dockerfile.

``` Dockerfile
RUN gem install dockable
ENTRYPOINT ["dockable"]
```

### Other commands

If the command is not available in your Procfile, it will simply be executed.

```
$ dockable ls -alh
```

Protip: to check if environments are loaded, try running `dockable env`.

### Other options

If `DOCKABLE_ROOT_DIR` is set, it will change the working directory.

You can change the location of the Procfile with `DOCKABLE_PROCFILE_LOCATION`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iain/dockable.

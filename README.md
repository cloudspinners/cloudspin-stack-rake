# Cloudspin::Stack::Rake

This Ruby library can be used in a Rakefile to manage infrastructure stacks. It makes use of the [cloudspin-stack](https://github.com/cloudspinners/cloudspin-stack) gem for the actual stack management code. The ideas behind this are documented (somewhat) in that project.

This is a prototype for an infrastructure project delivery framework. It is intended as a basis for exploring project structures, conventions, and functionality, but is not currently in a stable state.

Feel free to copy and use this, but be prepared to extend and modify it in order to make it useful for your own project. There isn't likely to be a clean path to upgrade your projects as this thing evolves - my assumption is that nobody else is directly depending on this code or the gems I've published from it.

I'm using [spin-stack-network](https://github.com/cloudspinners/spin-stack-network) as an example of an infrastructure stack project to make use of this framework. I may add other projects in the future as the tool is developed.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloudspin-stack-rake'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install cloudspin-stack-rake
```

## Usage: Stack management

Here's a snippet from a Rakefile:

```ruby
require 'cloudspin/stack/rake'

namespace :stack do
  namespace 'test-network' do
    Cloudspin::Stack::Rake::StackTask.new(id: 'test-network')
  end
end
```

If you run `rake -T` you'll see a list of tasks:

```bash
rake stack:test-network:down    # Destroy stack test-network
rake stack:test-network:dry     # Show command line to be run for stack test-network
rake stack:test-network:plan    # Plan changes to stack test-network
rake stack:test-network:up      # Create or update stack test-network
```

You can also add inspec test tasks. The Rakefile snippet:
```ruby
require 'cloudspin/stack/rake'

namespace :stack do
  namespace 'test-network' do
    stack = Cloudspin::Stack::Rake::StackTask.new(id: 'test-network').instance
    Cloudspin::Stack::Rake::InspecTask.new(stack_instance: stack,
                                           inspec_target: 'aws://eu-west-1/assume-spin_stack_manager-skeleton')
  end
end
```

This includes the stack management tasks from the first example, but adds a new one when you run `rake -T`:

```bash
rake stack:test-network:inspec  # Run inspec tests
```

This assumes you have a folder `./inspec` with profile and controls in it.

For convenience, you can add a top level task to your Rakefile that creates a stack, runs inspec, and then destroys it:

```ruby
desc 'Create, test, and destroy the stack'
task :full_test => [
  :'stack:test-network:up',
  :'stack:test-network:inspec',
  :'stack:test-network:down'
]
```

You can then simply run `rake full_test` to do this.

Again, [spin-stack-network](https://github.com/cloudspinners/spin-stack-network) has an example of this, and is likely to move ahead of this documentation.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cloudspin-stack-rake.

# Kitsune

TODO: Write a description here

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     kitsune:
       github: RX14/kitsune
   ```

2. Run `shards install`

## Usage

```crystal
require "kitsune"

class App
  include Kitsune::App(Kitsune::Context)
  
  def routes
    get "/" do |ctx|
      ctx.response << "KYAAAA~"
    end
  end
end

App.new.listen
```

```
Kitsune listening on http://localhost:8088
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/RX14/kitsune/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [RX14](https://github.com/RX14) - creator and maintainer

# slowproxy

HTTP proxy server that communicates origin server slowly to emulate slow client.
Do not access any server except managed by you.

## Installation

Requires Ruby 2.0.0 or later.

    $ gem install slowproxy

## Usage

Run `slowproxy`.

    $ slowproxy

And configure your application to use proxy server on `127.0.0.1:8989`.

You can set speed by argument (default: 128kbps).

    $ slowproxy 1mbps

You can set listening port (default: 8989).

    $ slowproxy --port 8080

Or view help.

    $ slowproxy --help

## Contributing

1. Fork it ( http://github.com/labocho/slowproxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

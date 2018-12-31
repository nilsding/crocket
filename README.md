# crocket

A Crystal wrapper for [Rocket][rocket].

Still a work-in-progress, and a proof-of-concept.  Caveat emptor!

## Installation

1. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  crocket:
    github: nilsding/crocket
```
2. Run `shards install`.  This will automatically build the librocket library as
   well (don't worry, it doesn't take long).

## Usage

Usage should be similar to normal Rocket, but with a more Crystal-ish API.

```crystal
require "crocket"

# Create a new SyncDevice
device = Crocket::SyncDevice.new("sync")

# Set up some callbacks
Crocket::SyncDevice.define_pause_callback do |should_pause|
  if should_pause
    audio_stream.pause
  else
    audio_stream.play
  end
end
Crocket::SyncDevice.define_set_row_callback do |row|
  seek_row_in_audio_stream(row)
end
Crocket::SyncDevice.define_is_playing_callback do
  audio_stream.playing?
end

# Connect to the Rocket editor
abort "failed to connect to host" unless device.tcp_connect("localhost")

# Get some tracks
clear_r = device["clear.r"]
clear_g = device["clear.g"]
clear_b = device["clear.b"]

loop do
  row = get_row_from_audio_stream
  unless device.update(row)
    device.tcp_connect("localhost")
  end

  # Do something with the values for the current row
  p [row, clear_r[row], clear_g[row], clear_b[row]]
end

# Save the tracks for later demo use
device.save_tracks
```

To compile your Crystal app with librocket in edit mode, simply run `shards
install`.

For demo/playback mode where it reads the tracks from files you need to define
the `sync_player` flag.  This can be achieved via `shards install
-Dsync_player`.

The edit mode methods are stubbed out when the app is compiled for demo mode.
This means that you do not need to manually surround the relevant edit methods
(e.g. `#tcp_connect`, `#save_tracks`, and the callbacks) with a `{% if
flag?(:sync_player) %}` check.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/nilsding/crocket/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Georg Gadinger](https://github.com/nilsding) - creator and maintainer

[rocket]: https://github.com/rocket/rocket

require "./ext/rocket"

module Crocket
  class Track
    # Creates a new instance of `Crocket::Track`.
    # This should not be called manually.
    def initialize(@sync_track : Rocket::SyncTrack*)
    end

    # Returns the name of this track
    def name
      String.new(@sync_track.value.name)
    end

    # `to_unsafe` returns the raw C pointer to this Rocket `sync_track` struct.
    #
    # Useful for when you need to call the library functions directly.
    #
    # For example:
    #
    # ```
    # device = Crocket::SyncDevice.new("sync")
    # track = device["camera:rot.y"]
    # p Crocket::Rocket.sync_find_key(track, 0)
    # ```
    def to_unsafe
      @sync_track
    end

    # Returns the value at *row*
    def get_val(row : Float) : Float
      Rocket.sync_get_val(@sync_track, row)
    end

    # Alias for `#get_val`
    def [](row : Float) : Float
      get_val(row)
    end
  end
end

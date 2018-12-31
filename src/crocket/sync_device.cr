require "./ext/rocket"
require "./track"

module Crocket
  class SyncDevice
    DEFAULT_PORT = Rocket::SYNC_DEFAULT_PORT

    @sync_device : Rocket::SyncDevice*

    {% unless flag?(:sync_player) %}
    @sync_callbacks = Rocket::SyncCb.new(
      pause: ->(data : Void*, flag : Int32) {
        # data is _always_ an instance of this class.
        # so we will unbox it first to get the correct callback
        instance = Box(Crocket::SyncDevice).unbox(data)
        instance.class.pause_callback.call(flag != 0)
      },
      set_row: ->(data : Void*, row : Int32) {
        instance = Box(Crocket::SyncDevice).unbox(data)
        instance.class.set_row_callback.call(row)
      },
      is_playing: ->(data : Void*) {
        instance = Box(Crocket::SyncDevice).unbox(data)
        instance.class.is_playing_callback.call ? 1 : 0
      }
    )
    {% end %}

    @@pause_callback : Bool -> = ->(flag : Bool) {}
    @@set_row_callback : Int32 -> = ->(row : Int32) {}
    @@is_playing_callback : -> Bool = ->{ false }

    # Creates a new instance of `Crocket::SyncDevice`.
    def initialize(base : String)
      @sync_device = Rocket.sync_create_device(base)
    end

    # Properly destroys the allocated sync device.
    def finalize
      Rocket.sync_destroy_device(@sync_device)
    end

    def base
      String.new(@sync_device.value.base)
    end

    # `to_unsafe` returns the raw C pointer to this Rocket `sync_device` struct.
    #
    # Useful for when you need to call the library functions directly.
    #
    # For example:
    #
    # ```
    # device = Crocket::SyncDevice.new("sync")
    # callbacks = Crocket::Rocket::SyncCb.new(
    #   pause: ->(d : Void*, flag : Int32) {},
    #   # ...
    # )
    #
    # # ...
    #
    # loop do
    #   row = get_current_row(some_audio_context)
    #   Crocket::Rocket.sync_update(device, row.floor, pointerof(callbacks), nil)
    # end
    # ```
    def to_unsafe
      @sync_device
    end

    {% if flag?(:sync_player) %}
    # No-op for playback (demo) mode.  Always returns `true`.
    def tcp_connect(hostname : String, port : UInt16 = DEFAULT_PORT) : Bool
      true
    end

    # No-op for playback (demo) mode.  Always returns `true`.
    def update(row : Int32) : Bool
      true
    end

    # No-op for playback (demo) mode.  Always returns `true`.
    def update(row : Float) : Bool
      true
    end

    # No-op for playback (demo) mode.  Always returns `true`.
    def save_tracks : Bool
      true
    end
    {% else %}
    # Connects to the Rocket editor listening on *hostname* at *port* via TCP.
    def tcp_connect(hostname : String, port : UInt16 = DEFAULT_PORT) : Bool
      Rocket.sync_tcp_connect(@sync_device, hostname, port) == 0
    end

    # Tells Rocket that we've moved to another *row*
    def update(row : Int32) : Bool
      Rocket.sync_update(@sync_device, row, pointerof(@sync_callbacks), Box.box(self)) == 0
    end

    # Tells Rocket that we've moved to another *row*
    #
    # Lazy shortcut for
    # ```
    #   device.update(row.floor.to_i)
    # ```
    def update(row : Float) : Bool
      update(row.floor.to_i)
    end

    # Saves the tracks to disk.
    def save_tracks : Bool
      Rocket.sync_save_tracks(@sync_device) == 0
    end
    {% end %}

    # Returns a track.
    def get_track(name : String)
      Track.new(Rocket.sync_get_track(@sync_device, name))
    end

    # Alias for `#get_track`.
    def [](name : String)
      get_track(name)
    end

    def self.define_pause_callback(&callback : Bool ->)
      @@pause_callback = callback
    end

    def self.define_set_row_callback(&callback : Int32 ->)
      @@set_row_callback = callback
    end

    def self.define_is_playing_callback(&callback : -> Bool)
      @@is_playing_callback = callback
    end

    protected def self.pause_callback
      @@pause_callback
    end

    protected def self.set_row_callback
      @@set_row_callback
    end

    protected def self.is_playing_callback
      @@is_playing_callback
    end
  end
end

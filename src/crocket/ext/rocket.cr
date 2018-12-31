module Crocket
  {% if flag?(:sync_player) %}
  @[Link(ldflags: "#{__DIR__}/../../../rocket/lib/librocket-player.a")]
  {% else %}
  @[Link(ldflags: "#{__DIR__}/../../../rocket/lib/librocket.a")]
  {% end %}
  lib Rocket
    # sync.h
    SYNC_DEFAULT_PORT = 1338u16

    # track.h
    enum KeyType
      KEY_STEP   # stay constant
      KEY_LINEAR # lerp to the next value
      KEY_SMOOTH # smooth curve to the next value
      KEY_RAMP
      KEY_TYPE_COUNT
    end

    # track.h
    struct TrackKey
      row : Int32
      value : LibC::Float
      type : KeyType
    end

    # track.h
    struct SyncTrack
      name : LibC::Char*
      keys : TrackKey*
      num_keys : Int32
    end

    {% unless flag?(:sync_player) %}
    # sync.h
    struct SyncCb
      pause : (Void*, Int32) -> Void
      set_row : (Void*, Int32) -> Void
      is_playing : (Void*) -> Int32
    end
    {% end %}

    # sync.h
    struct SyncIoCb
      # filename, mode
      open : (LibC::Char*, LibC::Char*) -> Void*
      # ptr, size, nitems, stream
      read : (Void*, LibC::SizeT, LibC::SizeT, Void*) -> LibC::SizeT
      # stream
      close : (Void*) -> Int32
    end

    # device.h
    struct SyncDevice
      base : LibC::Char*
      tracks : SyncTrack**
      num_tracks : LibC::SizeT

      {% unless flag?(:sync_player) %}
      row : Int32
      sock : Int32
      {% end %}

      io_cb : SyncIoCb
    end

    # sync.h
    fun sync_create_device(LibC::Char*) : SyncDevice*
    fun sync_destroy_device(SyncDevice*)
    {% unless flag?(:sync_player) %}
    fun sync_tcp_connect(SyncDevice*, LibC::Char*, UInt16) : Int32
    fun sync_update(SyncDevice*, Int32, SyncCb*, Void*) : Int32
    fun sync_save_tracks(SyncDevice*) : Int32
    {% end %}
    fun sync_set_io_cb(SyncDevice*, SyncIoCb*)
    fun sync_get_track(SyncDevice*, LibC::Char*) : SyncTrack*
    fun sync_get_val(SyncTrack*, LibC::Double) : LibC::Double

    # track.h
    fun sync_find_key(SyncTrack*, Int32) : Int32
    {% unless flag?(:sync_player) %}
    fun sync_set_key(SyncTrack*, TrackKey*) : Int32
    fun sync_del_key(SyncTrack*, Int32) : Int32
    {% end %}
  end
end

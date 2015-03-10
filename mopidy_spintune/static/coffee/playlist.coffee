class @Playlist
  
  constructor: ->
    console.log '[Playlist] init'
    @selectedTrack = 0
    @trackCount = 0

  set: (clickedTrack)->
    @clear()
    $('.song').each (i, el)=>
      if el.href is clickedTrack then @selectedTrack = @trackCount
      player.mopidy.tracklist.add([null, null, el.href])
      @trackCount++
    
    i = 0
    player.stop()
    while i <= @selectedTrack
      player.next()
      i++
    player.play()

  clear: ->
    player.mopidy.tracklist.clear()
    @trackCount = 0

  get: ->
    player.mopidy.tracklist.getTracks().then(@processCurrentPlaylist, console.error)
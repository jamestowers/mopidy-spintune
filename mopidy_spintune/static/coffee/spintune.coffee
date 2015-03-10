class @Spintune
  
  constructor: ->
    @$doc = $(document)
    @ready = false
    @mopidy = new Mopidy(
      callingConvention: 'by-position-or-by-name'
    )
    @libraries = []
    @playlist = new Playlist()

    @init()

  init: ->
    console.log '[Spintune] init()'

    #@mopidy.on console.log.bind(console)
    
    @mopidy.on "state:online", =>
      console.log '[Spintune] Mopidy online'
      @onReady()

    @mopidy.on "state:offline", ->
      console.log '[Spintune] Mopidy offline'

    @mopidy.on "reconnectionPending", ->
      console.log '[Spintune] Mopidy pending connection'

    @mopidy.on "reconnecting", ->
      console.log '[Spintune] Mopidy reconnecting'

    @mopidy.on "event:trackPlaybackStarted", ->
      console.log '[Spintune] Playing new song'
      player.showCurrentTrack()

    @$doc.on 'click', '.song', ->
      player.handleClick(this)
      false

    @$doc.on 'click', 'a.album-name', ->
      player.getAlbumTracks(this.href)
      false

  onReady: ->
    @ready = true
    @showCurrentTrack()
    @getLibraries()
    @getLibraryTracks('spotify:toplist:current')

  handleClick: (e)->
    @playlist.set(e.href)

  trackInfo: (track) ->
    'Now playing: <a href="' + track.uri + '" class="track-name">' + track.name + '</a> by <a href="' + track.artists[0].uri + '" class="artist-name">' + track.artists[0].name + '</a> from <a href="' + track.album.uri + '" class="album-name">' + track.album.name + '</a>'

  showCurrentTrack: ->
    @mopidy.playback.getCurrentTrack().then (track) ->
      $('.playing-bar').html player.trackInfo(track)


  ##################################################################
  # CONTROLS

  play: (url)->
    @mopidy.playback.play().then ->

  stop: ->
    console.log '[Spintune] stopping'
    @mopidy.playback.stop([true])

  next: ->
    @mopidy.playback.next()



  ##################################################################
  #LIBRARY

  getLibraries: ->
    @mopidy.library.browse({'uri':null}).then (data) ->
      $.each data, (i,e)->
        player.libraries[e.name] = 
          'uri': e.uri
          'type': e.type

  getLibraryTracks: (rootDir)->
    @mopidy.library.browse({'uri': rootDir}).then(@printTrackList, console.error)

  getAlbumTracks: (uri)->
    @mopidy.library.browse({'uri': uri}).then(@printTrackList, console.error)
    albumId = uri.substr(uri.lastIndexOf(":") + 1)
    @getSpotifyArtwork(albumId, @showArtwork)

  showArtwork: (imgData)->
    console.log imgData
    html = '<div class="thumb artwork" id="album-artwork"><img src="' + imgData.url + '" /></div>'
    $(html).insertBefore('#tracklist')

  printTrackList: (resultArr)->
    if !resultArr or resultArr == '' or resultArr.length == 0
      console.log 'No tracks found'
    else
      html = '';
      $('#tracklist').empty()

      i = 0
      while i < resultArr.length
        if resultArr[i].type == 'track'
          html += '<li><a href="' + resultArr[i].uri + '" data-url="' + resultArr[i].uri + '" class="song"><span class="song-name"> ' + resultArr[i].name + '</span></a></li>'
        else
          console.log 'It\'s a directory'
        i++
      $('#tracklist').html html


  getSpotifyArtwork: (albumId, cb)->
    return $.ajax
      url: 'https://api.spotify.com/v1/albums/' + albumId
      dataType: 'json'
      processData: false
      success: (data) ->
        cb(data.images[0])
      error: (error)->
        console.log error

      
  getCurrentTrack: ->
    @mopidy.playback.getCurrentTrack({}).then (data) ->
      console.log data
      return data

  powerDown: ->
    @mopidy.close()
    @mopidy.off()
    @mopidy = null
App Cache
=========

Some helpers for working with HTML5 application cache.

http://www.html5rocks.com/en/tutorials/appcache/beginner/

    applicationCache = window.applicationCache
    
    applicationCache.addEventListener 'updateready', (e) ->
      if applicationCache.status is applicationCache.UPDATEREADY
        # Browser downloaded a new app cache.
        if confirm('A new version of this site is available. Load it?')
          window.location.reload()
    , false

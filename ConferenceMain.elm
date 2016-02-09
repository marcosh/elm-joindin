import Conference exposing (init, update, view)

import StartApp exposing (start)
import Effects exposing (Never)
import Task exposing (Task)

app =
  start
    { init = init
        "SunshinePHP 2016"
        "sunshinephp-2016"
        "The large PHP community in South Florida has organized its third annual PHP developer conference in Miami, and you're invited!"
        "http://sunshinephp.com"
        "http://api.joind.in/v2.1/events/4525"
        ( Just "sphp_joindin3.png" )
        "http://api.joind.in/v2.1/events/4525/talks"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal ( Task.Task Never () )
port tasks =
  app.tasks
import Joindin exposing (init, update, view)

import StartApp exposing (start)
import Effects exposing (Never)
import Task exposing (Task)

app =
  start
    { init = init "http://api.joind.in/v2.1/events?filter=past&verbose=yes"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal ( Task.Task Never () )
port tasks =
  app.tasks
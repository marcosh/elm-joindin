import Conference exposing (init, update, view)

import StartApp exposing (start)
import Effects exposing (Never)
import Task exposing (Task)

app =
  start
    { init = init
        "SymfonyCon Paris 2015"
        "symfonycon-paris-2015"
        "SensioLabs is proud to organize the third edition of the SymfonyCon"
        "http://pariscon2015.symfony.com/"
        "https://joind.in/event/symfonycon-paris-2015"
        "http://api.joind.in/v2.1/events/4063/talks"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal ( Task.Task Never () )
port tasks =
  app.tasks
import Joindin exposing (init, update, view)
import Config exposing (apiProtocol, apiHost, apiPort)

import StartApp exposing (start)
import Effects exposing (Never)
import Task exposing (Task)

app =
    let
        apiUri = apiProtocol
            ++ "://"
            ++ apiHost
            ++ ":"
            ++ ( toString apiPort )
            ++ "/v2.1/events?filter=past&verbose=yes"
    in
        start
            { init = init apiUri
            , update = update
            , view = view
            , inputs = []
            }


main =
    app.html


port tasks : Signal ( Task.Task Never () )
port tasks =
    app.tasks
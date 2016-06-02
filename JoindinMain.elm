module JoindinMain exposing (..)

import Joindin exposing (init, update, view)
import Config exposing (apiProtocol, apiHost, apiPort)
import Html.App as Html


subscriptions : Joindin.Joindin -> Sub Joindin.Msg
subscriptions joindin =
    Sub.none


main =
    let
        apiUri =
            apiProtocol
                ++ "://"
                ++ apiHost
                ++ ":"
                ++ (toString apiPort)
                ++ "/v2.1/events?filter=past&verbose=yes"
    in
        Html.program
            { init = init apiUri
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

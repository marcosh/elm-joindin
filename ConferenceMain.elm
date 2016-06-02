module Main exposing (..)

import Conference exposing (init, update, view)
import Html.App as Html


subscriptions : Conference.Conference -> Sub Conference.Msg
subscriptions conference =
    Sub.none


main =
    Html.program
        { init =
            init "SunshinePHP 2016"
                "sunshinephp-2016"
                "The large PHP community in South Florida has organized its third annual PHP developer conference in Miami, and you're invited!"
                "http://sunshinephp.com"
                "http://api.joind.in/v2.1/events/4525"
                (Just "sphp_joindin3.png")
                "http://api.joind.in/v2.1/events/4525/talks"
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

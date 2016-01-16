import Talk exposing (init, update, view)
import StartApp.Simple exposing (start)


main =
  start
    { model = init "title" "description" "stub" "" "uri" [ "me", "you" ]
    , update = update
    , view = view
    }

import Talk exposing (Talk, update, view)
import StartApp.Simple exposing (start)


main =
  start
    { model = Talk "title" "description" "stub" "" "uri" [ "me", "you" ]
    , update = update
    , view = view
    }

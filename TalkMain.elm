module TalkMain exposing (..)

import Talk exposing (Talk, update, view)
import Html.App as Html


main =
    Html.beginnerProgram
        { model = Talk "Elm or how I learned to love front-end development" "Front-end development is rapidly evolving, with new frameworks coming and going at a crazy pace. Among the many options, Elm stands out as one of the most original and promising approaches: it combines the principles of reactive programming with the elegance of strongly typed functional programming, yet providing a seamless integration with javascript code. In this talk Marco will introduce Elm, exploring a real project built with it. He will dig into the best language features, also exposing how Elm can foster the development of modular, reusable and testable front-end architectures." "stub" "" "uri" [ "Marco Perone" ]
        , update = update
        , view = view
        }

module Talk where

import Html exposing (Html, div, text, a, span)
import Html.Attributes exposing (href)
import Signal exposing (Address)
import List exposing (map, intersperse)
import Json.Decode exposing (Decoder, string, object1, object6, list, (:=))
import String exposing (isEmpty)

-- MODEL

type alias Talk =
    { title : String
    , description : String
    , stub : String
    , slides_link : String
    , uri : String
    , speakers : List String
    }

init : String -> String -> String -> String -> String -> List String -> Talk
init title description stub slides_link uri speakers =
    Talk title description stub slides_link uri speakers

-- UPDATE

type Action = NoOp

update : Action -> Talk -> Talk
update action talk = talk

-- VIEW

view : Address Action -> Talk -> Html
view address talk =
  div []
    [ div [] [ a [ href talk.uri ] [ text talk.title ]
        , text " by "
        , span [] ( map spanWrap ( intersperse  ", " talk.speakers ))
        ]
    , divWrap talk.description
    , a [ href talk.slides_link ] [ text "Slides" ]
    ]

divWrap : String -> Html
divWrap string = div [] [ text string ]

spanWrap : String -> Html
spanWrap string = span [] [ text string ]

-- slidesLink : String -> Html
-- slidesLink link = if isEmpty link
--     then text ""
--     else a [ href link ] [ text "Slides" ]

-- OTHER

talkDecoder : Decoder Talk
talkDecoder = object6 Talk
    ( "talk_title" := string )
    ( "talk_description" := string )
    ( "stub" := string )
    ( "slides_link" := string )
    ( "website_uri" := string )
    ( "speakers" := list speakerDecoder )

speakerDecoder : Decoder String
speakerDecoder = object1 identity
    ( "speaker_name" := string )

stubTalk : Talk -> ( String, Talk )
stubTalk talk = ( talk.stub, talk )

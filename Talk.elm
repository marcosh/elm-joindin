module Talk exposing (..)

import Html exposing (Html, div, text, a, span)
import Html.Attributes exposing (href, class, target)
import Html.Events exposing (onClick)
import List exposing (map, intersperse)
import Json.Decode exposing (Decoder, string, object1, object6, list, (:=))
import String exposing (isEmpty)
import ElmEscapeHtml exposing (unescape)


-- MODEL


type alias Talk =
    { title : String
    , description : String
    , stub : String
    , slides_link : String
    , uri : String
    , speakers : List String
    }



-- UPDATE


type Msg
    = ClickTitle
    | ClickDescription


update : Msg -> Talk -> Talk
update msg talk =
    case msg of
        ClickTitle ->
            talk

        ClickDescription ->
            { talk | description = "We got a new description!" }



-- VIEW


view : Talk -> Html Msg
view talk =
    div [ class "talk" ]
        [ div [ onClick ClickTitle ]
            [ a [ href talk.uri, class "title", target "_blank" ] [ text talk.title ]
            , text " by "
            , span [] (map spanWrap (intersperse ", " talk.speakers))
            ]
        , div [ onClick ClickDescription ] [ text (unescape talk.description) ]
        ]


divWrap : String -> Html Msg
divWrap string =
    div [] [ text string ]


spanWrap : String -> Html Msg
spanWrap string =
    span [] [ text string ]



-- slidesLink : String -> Html
-- slidesLink link = if isEmpty link
--     then text ""
--     else a [ href link ] [ text "Slides" ]
-- OTHER


talkDecoder : Decoder Talk
talkDecoder =
    object6 Talk
        ("talk_title" := string)
        ("talk_description" := string)
        ("stub" := string)
        ("slides_link" := string)
        ("website_uri" := string)
        ("speakers" := list speakerDecoder)


speakerDecoder : Decoder String
speakerDecoder =
    object1 identity
        ("speaker_name" := string)


stubTalk : Talk -> ( String, Talk )
stubTalk talk =
    ( talk.stub, talk )

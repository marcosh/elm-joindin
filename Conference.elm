module Conference where

import Talk exposing (Talk, talkDecoder, stubTalk)

import Effects exposing (Effects, none, task)
import Html exposing (Html, div, h2, text)
import Signal exposing (Address, forwardTo)
import Http exposing (get)
import Json.Decode exposing (Decoder, object1, object6, list, string, (:=))
import Task exposing (toMaybe)
import List exposing (filter)
import String

-- MODEL

type alias Talks = List (String, Talk)

type alias Conference =
    { name : String
    , urlFrienlyName : String
    , description : String
    , uri : String
    , joindinUri : String
    , talksUri : String
    , talks : Talks
    }

init : String -> String -> String -> String -> String -> String -> ( Conference, Effects Action )
init name urlFrienlyName description uri joindinUri talksUri =
    ( build name urlFrienlyName description uri joindinUri talksUri
    , retrieveTalks ( talksUri ++ "?verbose=yes" )
    )

build : String -> String -> String -> String -> String -> String -> Conference
build name urlFrienlyName description uri joindinUri talksUri =
    Conference name urlFrienlyName description uri joindinUri ( talksUri ++ "?verbose=yes" ) []

-- UPDATE

type Action
    = TalksRetrieved ( Maybe Talks )
    | Forward String Talk.Action

update : Action -> Conference -> ( Conference, Effects Action )
update action conference =
    case action of
        TalksRetrieved maybeTalks ->
            ( addTalks conference maybeTalks, none )
        Forward stub action ->
            ( conference, none )

addTalks : Conference -> Maybe Talks -> Conference
addTalks conference maybeTalks =
    Conference
        conference.name
        conference.urlFrienlyName
        conference.description
        conference.uri
        conference.joindinUri
        conference.talksUri
        -- ( Maybe.withDefault [] maybeTalks ) -- this shows all the talks
        ( filterTalksWithSlides maybeTalks )

filterTalksWithSlides : Maybe Talks -> Talks
filterTalksWithSlides maybeTalks =
    case maybeTalks of
        Nothing
            -> []
        Just talks
            -> filter ( \( stub, talk ) -> not ( String.isEmpty talk.slides_link )) talks


-- VIEW

view : Address Action -> Conference -> Html
view address conference =
    if
        List.isEmpty conference.talks
    then
        text ""
    else
        let
            conferenceNameHeader = ( h2 [] [ text conference.name ] )
            conferenceTalks = ( List.map ( viewTalk address ) conference.talks )
        in
        div []
            ( conferenceNameHeader :: conferenceTalks )

viewTalk : Address Action -> ( String, Talk ) -> Html
viewTalk address ( stub, talk ) =
    Talk.view ( forwardTo address ( Forward stub )) talk

-- EFFECTS

retrieveTalks : String -> Effects Action
retrieveTalks uri =
    get decoder uri
    |> toMaybe
    |> Task.map TalksRetrieved
    |> task

decoder : Decoder Talks
decoder = object1 identity
    ( "talks" := list ( Json.Decode.map stubTalk talkDecoder ))

-- OTHER

decoderConference : Decoder Conference
decoderConference = object6 build
    ( "name" := string )
    ( "url_friendly_name" := string )
    ( "description" := string )
    ( "website_uri" := string )
    ( "uri" := string )
    ( "talks_uri" := string )

idConference : Conference -> ( String, Conference )
idConference conference = ( conference.urlFrienlyName, conference )

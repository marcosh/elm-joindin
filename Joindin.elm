module Joindin where

import Conference exposing (Conference, decoderConference, idConference)

import Effects exposing (Effects, none, task, batch)
import Html exposing (Html, div, h1, span, a, header, footer, text)
import Html.Attributes exposing (class, href)
import Signal exposing (Address, forwardTo)
import Http exposing (get)
import Json.Decode exposing (Decoder, object1, list, (:=))
import Task exposing (toMaybe, succeed)

-- MODEL

--type alias SimpleConferences = List Conference

type alias Conferences = List (String, Conference)

type alias Joindin =
    { conferences : Conferences
    }

init : String -> ( Joindin, Effects Action )
init conferencesUri =
    ( Joindin []
    , retrieveConferences conferencesUri
    )

-- UPDATE

type Action
    = ConferencesRetrieved ( Maybe Conferences )
    | RetrieveTalks
    | Forward String Conference.Action
--    | SimpleConfereceRetrieved ( Maybe SimpleConferences )

update : Action -> Joindin -> ( Joindin, Effects Action )
update action joindin =
    case action of
        ConferencesRetrieved maybeConferences ->
            ( addConferences joindin maybeConferences, task ( succeed RetrieveTalks ))
        RetrieveTalks ->
            ( joindin, batch ( List.map retrieveTalkEffect joindin.conferences ))
        Forward id conferenceAction ->
            let updateConference (( conferenceId, conference ) as entry ) =
                if id == conferenceId
                then
                    let
                        ( newConference, effect ) = Conference.update conferenceAction conference
                    in
                        (( conferenceId, newConference )
                        , Effects.map ( Forward id ) effect
                        )
                else ( entry, none )

                ( newConferences, effectsList ) =
                    joindin.conferences
                        |> List.map updateConference
                        |> List.unzip
            in
                ( { joindin | conferences = newConferences}
                , batch effectsList
                )



--        SimpleConfereceRetrieved maybeConferences ->
--            ( joindin, none )

addConferences : Joindin -> Maybe Conferences -> Joindin
addConferences joindin maybeConferences =
    Joindin ( Maybe.withDefault [] maybeConferences )

retrieveTalkEffect : ( String, Conference ) -> Effects Action
retrieveTalkEffect ( id, conference ) =
    Effects.map ( Forward id ) ( Conference.retrieveTalks conference.talksUri )

-- VIEW

view : Address Action -> Joindin -> Html
view address joindin =
    let
        title = header []
            [ h1 []
                [ text  "The "
                , span [ class "cursive" ] [ text "slides" ]
                , text " archive"
                ]
            ]
        conferences = List.map ( viewConference address ) joindin.conferences
        foot = footer []
            [ div []
                [ text "This page is realized using the data exposed by the "
                , a [ href "https://joind.in/" ] [ text "Joind.in" ]
                , text " API's."
                ]
            , div []
                [ text "This page is made using "
                , a [ href "http://elm-lang.org/" ] [ text "ELM" ]
                , text ", a rective funtional programming language that runs in the browser. You can find the source code on "
                , a [ href "https://github.com/marcosh/elm-joindin" ] [ text "https://github.com/marcosh/elm-joindin" ]
                , text ", contributions are more than welcome!"
                ]
            ]
    in
        div []
            ( List.concat [ title :: conferences, [ foot ]])

viewConference : Address Action -> ( String, Conference ) -> Html
viewConference address ( id, conference ) =
    Conference.view ( forwardTo address ( Forward id )) conference

-- EFFECTS

retrieveConferences : String -> Effects Action
retrieveConferences uri = get decoder uri
    |> toMaybe
    |> Task.map ConferencesRetrieved
    |> task

decoder : Decoder Conferences
decoder = object1 identity
    ( "events" := list ( Json.Decode.map idConference decoderConference ))

module Joindin exposing (..)

import Conference exposing (Conference, decoderConference, idConference)
import Html exposing (Html, div, h1, h3, span, a, header, footer, text)
import Html.App as App
import Html.Attributes exposing (class, href)
import Http exposing (get)
import Json.Decode exposing (Decoder, object1, list, (:=))
import Task exposing (toMaybe, succeed)


-- MODEL
--type alias SimpleConferences = List Conference


type alias Conferences =
    List ( String, Conference )


type alias Joindin =
    { conferences : Conferences
    }


init : String -> ( Joindin, Cmd Msg )
init conferencesUri =
    ( Joindin []
    , retrieveConferences conferencesUri
    )



-- UPDATE


type Msg
    = FetchConferences String
    | ConferencesRetrieved (Maybe Conferences)
    | FetchFailed Http.Error
    | Forward String Conference.Msg



--    | SimpleConfereceRetrieved ( Maybe SimpleConferences )


update : Msg -> Joindin -> ( Joindin, Cmd Msg )
update msg joindin =
    case msg of
        FetchConferences uri ->
            ( joindin, retrieveConferences uri )

        ConferencesRetrieved maybeConferences ->
            let
                newJoindin =
                    addConferences joindin maybeConferences
            in
                ( newJoindin, Cmd.batch (List.map retrieveTalks newJoindin.conferences) )

        FetchFailed error ->
            ( joindin, Cmd.none )

        Forward id conferenceAction ->
            let
                updateConference (( conferenceId, conference ) as entry) =
                    if id == conferenceId then
                        let
                            ( newConference, cmd ) =
                                Conference.update conferenceAction conference
                        in
                            ( ( conferenceId, newConference )
                            , Cmd.map (Forward id) cmd
                            )
                    else
                        ( entry, Cmd.none )

                ( newConferences, effectsList ) =
                    joindin.conferences
                        |> List.map updateConference
                        |> List.unzip
            in
                ( { joindin | conferences = newConferences }
                , Cmd.batch effectsList
                )



--        SimpleConfereceRetrieved maybeConferences ->
--            ( joindin, none )


addConferences : Joindin -> Maybe Conferences -> Joindin
addConferences joindin maybeConferences =
    Joindin (Maybe.withDefault [] maybeConferences)


retrieveTalks : ( String, Conference ) -> Cmd Msg
retrieveTalks ( id, conference ) =
    Cmd.map (Forward id) (Conference.retrieveTalks conference.talksUri)



-- VIEW


view : Joindin -> Html Msg
view joindin =
    let
        title =
            header []
                [ h1 []
                    [ text "The "
                    , span [ class "cursive" ] [ text "slides" ]
                    , text " archive"
                    ]
                , h3 [ class "subtitle" ]
                    [ text "Did you miss a conference? Here you will find all the latest slides uploaded on "
                    , a [ href "https://joind.in/" ] [ text "Joind.in" ]
                    , text " by the most amazing speakers in the wild!"
                    ]
                ]

        conferences =
            List.map viewConference joindin.conferences

        foot =
            footer []
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
            (List.concat [ title :: conferences, [ foot ] ])


viewConference : ( String, Conference ) -> Html Msg
viewConference ( id, conference ) =
    App.map (Forward id) (Conference.view conference)



-- EFFECTS


retrieveConferences : String -> Cmd Msg
retrieveConferences uri =
    Task.perform FetchFailed
        ConferencesRetrieved
        (get decoder uri
            |> toMaybe
        )


decoder : Decoder Conferences
decoder =
    object1 identity
        ("events" := list (Json.Decode.map idConference decoderConference))

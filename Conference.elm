module Conference exposing (..)

import Talk exposing (Talk, talkDecoder, stubTalk)
import Config exposing (apiProtocol, apiHost, apiPort)
import Html exposing (Html, div, h2, text, img)
import Html.App as App
import Html.Attributes exposing (class, src)
import Http exposing (get)
import Json.Decode exposing (Decoder, object1, object7, list, string, (:=), maybe)
import Task exposing (toMaybe)
import List exposing (filter)
import String exposing (split)
import Erl exposing (parse, toString)


-- MODEL


type alias Talks =
    List ( String, Talk )


type alias Conference =
    { name : String
    , urlFrienlyName : String
    , description : String
    , uri : String
    , joindinUri : String
    , icon : Maybe String
    , talksUri : String
    , talks : Talks
    }


realTalksUri : String -> String
realTalksUri talksUri =
    let
        splittedApiHost =
            split "." apiHost
    in
        talksUri
            |> parse
            |> (\uri -> { uri | host = splittedApiHost, protocol = apiProtocol, port' = apiPort })
            |> Erl.toString
            |> (\uri -> uri ++ "?verbose=yes&resultsperpage=0")


init : String -> String -> String -> String -> String -> Maybe String -> String -> ( Conference, Cmd Msg )
init name urlFrienlyName description uri joindinUri icon talksUri =
    ( build name urlFrienlyName description uri joindinUri icon talksUri
    , retrieveTalks (realTalksUri talksUri)
    )


build : String -> String -> String -> String -> String -> Maybe String -> String -> Conference
build name urlFrienlyName description uri joindinUri icon talksUri =
    Conference name urlFrienlyName description uri joindinUri icon (realTalksUri talksUri) []



-- UPDATE


type Msg
    = FetchTalks String
    | TalksRetrieved (Maybe Talks)
    | FetchFailed Http.Error
    | Forward String Talk.Msg


update : Msg -> Conference -> ( Conference, Cmd Msg )
update msg conference =
    case msg of
        FetchTalks uri ->
            ( conference, retrieveTalks uri )

        TalksRetrieved maybeTalks ->
            ( addTalks maybeTalks conference, Cmd.none )

        FetchFailed error ->
            ( conference, Cmd.none )

        Forward stub subMsg ->
            let
                ( newTalks, cmds ) =
                    List.unzip (List.map (updateHelp stub subMsg) conference.talks)
            in
                ( { conference | talks = newTalks }
                , Cmd.batch cmds
                )


updateHelp : String -> Talk.Msg -> ( String, Talk ) -> ( ( String, Talk ), Cmd Msg )
updateHelp stub msg ( talkStub, talk ) =
    if talkStub /= stub then
        ( ( stub, talk ), Cmd.none )
    else
        let
            newTalk =
                Talk.update msg talk
        in
            ( ( stub, newTalk )
            , Cmd.map (Forward stub) Cmd.none
            )


addTalks : Maybe Talks -> Conference -> Conference
addTalks maybeTalks conference =
    Conference conference.name
        conference.urlFrienlyName
        conference.description
        conference.uri
        conference.joindinUri
        conference.icon
        conference.talksUri
        -- ( Maybe.withDefault [] maybeTalks ) -- this shows all the talks
        (filterTalksWithSlides maybeTalks)


filterTalksWithSlides : Maybe Talks -> Talks
filterTalksWithSlides maybeTalks =
    case maybeTalks of
        Nothing ->
            []

        Just talks ->
            filter (\( stub, talk ) -> not (String.isEmpty talk.slides_link)) talks



-- VIEW


view : Conference -> Html Msg
view conference =
    if List.isEmpty conference.talks then
        text ""
    else
        let
            iconPath =
                case conference.icon of
                    Just path ->
                        "https://joind.in/inc/img/event_icons/" ++ path

                    Nothing ->
                        "https://joind.in/img/event_icons/none.png"

            conferenceLogo =
                img
                    [ src iconPath
                    , class "logo"
                    ]
                    []

            conferenceName =
                (h2 [] [ text conference.name ])

            conferenceHeader =
                div [ class "conferenceHeader" ]
                    [ conferenceLogo
                    , conferenceName
                    ]

            conferenceTalks =
                (List.map viewTalk conference.talks)
        in
            div [ class "conference" ]
                (conferenceHeader :: conferenceTalks)


viewTalk : ( String, Talk ) -> Html Msg
viewTalk ( stub, talk ) =
    App.map (Forward stub) (Talk.view talk)



-- EFFECTS


retrieveTalks : String -> Cmd Msg
retrieveTalks uri =
    Task.perform FetchFailed
        TalksRetrieved
        (get decoder uri
            |> toMaybe
        )


decoder : Decoder Talks
decoder =
    object1 identity
        ("talks" := list (Json.Decode.map stubTalk talkDecoder))



-- OTHER


decoderConference : Decoder Conference
decoderConference =
    object7 build
        ("name" := string)
        ("url_friendly_name" := string)
        ("description" := string)
        ("website_uri" := string)
        ("uri" := string)
        (maybe ("icon" := string))
        ("talks_uri" := string)


idConference : Conference -> ( String, Conference )
idConference conference =
    ( conference.urlFrienlyName, conference )

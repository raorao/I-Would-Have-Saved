module Router exposing (..)

import UrlParser exposing (..)
import Navigation
import Regex
import Model


type Route
    = LoggedOut
    | LoggedIn


routeTable : Parser (Route -> a) a
routeTable =
    oneOf
        [ map LoggedIn (s "home")
        , map LoggedOut top
        ]


parseLocation : Navigation.Location -> Maybe Route
parseLocation =
    parsePath routeTable


parseAccessToken : Navigation.Location -> Maybe Model.AccessToken
parseAccessToken location =
    let
        matcher =
            Regex.regex "#access_token=(.*)"
    in
        location.hash
            |> Regex.find (Regex.AtMost 1) matcher
            |> List.head
            |> Maybe.map .submatches
            |> Maybe.andThen List.head
            |> Maybe.andThen identity

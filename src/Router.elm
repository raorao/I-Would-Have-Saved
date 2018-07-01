module Router exposing (..)

import UrlParser exposing (..)
import Navigation
import Regex
import Model exposing (AccessToken(..))


type Route
    = LoggedOut
    | LoggedIn


routeTable : Parser (Route -> Route) Route
routeTable =
    oneOf
        [ map LoggedIn (s "home")
        , map LoggedOut top
        ]


parseLocation : Navigation.Location -> ( Maybe Route, Maybe AccessToken )
parseLocation location =
    ( parsePath routeTable location
    , parseAccessToken location
    )


parseAccessToken : Navigation.Location -> Maybe AccessToken
parseAccessToken location =
    location.hash
        |> Regex.find (Regex.AtMost 1) (Regex.regex "#access_token=(.*)")
        |> List.head
        |> Maybe.map .submatches
        |> Maybe.andThen List.head
        |> Maybe.andThen identity
        |> Maybe.map AccessToken

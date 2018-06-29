module Model exposing (..)

import RemoteData exposing (..)
import Http


type alias Config =
    { ynab_client_id : String
    , ynab_redirect_uri : String
    }


type Page
    = LoggedIn
    | LoggedOut
    | Error


type alias Model =
    { config : Config
    , page : Page
    , token : Maybe AccessToken
    , transactions : RemoteData Http.Error (List String)
    }


type alias AccessToken =
    String

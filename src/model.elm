module Model exposing (..)

import RemoteData exposing (..)
import Http


type alias Config =
    { ynab_client_id : String
    , ynab_redirect_uri : String
    }


type Page
    = LoggedIn
    | BudgetSelector
    | LoggedOut
    | Error


type alias Model =
    { config : Config
    , page : Page
    , token : Maybe AccessToken
    , budgets : RemoteData Http.Error (List Budget)
    }


type alias AccessToken =
    String


type alias Budget =
    { id : String
    , name : String
    }

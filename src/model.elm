module Model exposing (..)


type alias Config =
    { ynab_client_id : String
    , ynab_redirect_uri : String
    }


type alias Model =
    { config : Config
    , pageModel : PageModel
    }


type alias AccessToken =
    String


type PageModel
    = LoggedOut
    | LoggedIn AccessToken
    | Error

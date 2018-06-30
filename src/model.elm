module Model exposing (..)

import RemoteData exposing (..)
import Http
import List.Zipper exposing (Zipper)
import Date exposing (Date)
import DatePicker


type alias Config =
    { ynab_client_id : String
    , ynab_redirect_uri : String
    }


type Page
    = Loading
    | BudgetSelector
    | TransactionViewer
    | LoggedOut
    | Error


type CategoryFilter
    = CategoryFilter String


type SinceFilter
    = SinceFilter Date


type alias Filters =
    { category : Maybe CategoryFilter
    , since : Maybe SinceFilter
    , adjustment : Maybe Adjustment
    }


type Adjustment
    = Adjustment Float


type alias Model =
    { config : Config
    , page : Page
    , token : Maybe AccessToken
    , budgets : RemoteData Http.Error (Zipper Budget)
    , transactions : RemoteData Http.Error (List Transaction)
    , filters : Filters
    , datePicker : DatePicker.DatePicker
    }


type alias AccessToken =
    String


type alias BudgetId =
    String


type alias Budget =
    { id : BudgetId
    , name : String
    }


type alias Transaction =
    { id : String
    , amount : Int
    , category : String
    , payee : String
    , date : Date
    }


emptyFilters : Filters
emptyFilters =
    Filters Nothing Nothing Nothing

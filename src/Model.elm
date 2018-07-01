module Model exposing (..)

import List.Zipper exposing (Zipper)
import Date exposing (Date)
import DatePicker
import Http


type alias Config =
    { ynab_client_id : String
    , ynab_redirect_uri : String
    }


type ErrorType
    = NoAccessToken
    | ApiDown Http.Error
    | InvalidRoute
    | ImpossibleState


type alias TransactionViewerData =
    { transactions : List Transaction
    , filters : Filters
    , datePicker : DatePicker.DatePicker
    }


type alias BudgetSelectorData =
    { budgets : Zipper Budget
    }


type Page
    = Loading String
    | BudgetSelector BudgetSelectorData
    | TransactionViewer TransactionViewerData
    | LoggedOut
    | Error ErrorType


type CategoryFilter
    = CategoryFilter String


type SinceFilter
    = SinceFilter Date


type Adjustment
    = Adjustment Float


type alias Filters =
    { category : Maybe CategoryFilter
    , since : Maybe SinceFilter
    , adjustment : Maybe Adjustment
    }


type alias Model =
    { config : Config
    , page : Page
    , token : Maybe AccessToken
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
    , category : Maybe String
    , payee : Maybe String
    , date : Date
    }


emptyFilters : Filters
emptyFilters =
    Filters Nothing Nothing Nothing


defaultBudget : Budget
defaultBudget =
    Budget "default" "default"

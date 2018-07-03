module Model exposing (..)

import Date exposing (Date)
import DatePicker
import Http
import Bootstrap.Dropdown as Dropdown


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
    , viewState : TransactionViewerViewState
    , datePicker : DatePicker.DatePicker
    }


type TransactionViewerDropdown
    = CategoryDropdown
    | AdjustmentDropdown


type alias TransactionViewerViewState =
    { adjustmentDropdown : Dropdown.State
    , categoryDropdown : Dropdown.State
    }


type alias BudgetSelectorData =
    { budgets : List Budget
    , token : AccessToken
    }


type LoadingType
    = LoadingBudgets
    | LoadingTransactions


type Model
    = Loading LoadingType
    | BudgetSelector BudgetSelectorData
    | TransactionViewer TransactionViewerData
    | LoggedOut Config
    | Error ErrorType


type CategoryFilter
    = CategoryFilter String


type SinceFilter
    = SinceFilter Date


type AdjustmentFilter
    = HalfAsMuch
    | TenPercent
    | TwentyFivePercent
    | NothingAtAll


type Filter f
    = Inactive
    | Active f


type alias Filters =
    { category : Filter CategoryFilter
    , since : Filter SinceFilter
    , adjustment : Filter AdjustmentFilter
    }


type AccessToken
    = AccessToken String


type BudgetId
    = BudgetId String


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
    Filters Inactive Inactive Inactive


initialViewState : TransactionViewerViewState
initialViewState =
    { adjustmentDropdown = Dropdown.initialState
    , categoryDropdown = Dropdown.initialState
    }

module Model exposing (..)

import Date exposing (Date)
import DatePicker
import Http
import Bootstrap.Dropdown as Dropdown
import Html.Attributes


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
    | PayeeDropdown


type alias TransactionViewerViewState =
    { adjustmentDropdown : Dropdown.State
    , categoryDropdown : Dropdown.State
    , payeeDropdown : Dropdown.State
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


type PayeeFilter
    = PayeeFilter String


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
    , payee : Filter PayeeFilter
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
    { category = Inactive
    , since = Inactive
    , adjustment = Inactive
    , payee = Inactive
    }


initialViewState : TransactionViewerViewState
initialViewState =
    { adjustmentDropdown = Dropdown.initialState
    , categoryDropdown = Dropdown.initialState
    , payeeDropdown = Dropdown.initialState
    }


datePickerSettings : DatePicker.Settings
datePickerSettings =
    let
        defaultSettings =
            DatePicker.defaultSettings
    in
        { defaultSettings
            | placeholder = "..."
            , inputAttributes =
                [ Html.Attributes.class "form-control form-control-lg"
                , Html.Attributes.style [ ( "text-align", "center" ) ]
                ]
        }

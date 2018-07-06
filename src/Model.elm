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


type FilterType
    = CategoryFilter (Filter String)
    | PayeeFilter (Filter String)
    | SinceFilter (Filter Date)
    | AdjustmentFilter (Filter AdjustmentFilterVal)


type AdjustmentFilterVal
    = HalfAsMuch
    | TenPercent
    | TwentyFivePercent


type Filter a
    = Active a
    | Inactive


type alias TransactionViewerData =
    { transactions : List Transaction
    , filters : List FilterType
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
    | PrivacyPolicy


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


emptyFilters : List FilterType
emptyFilters =
    [ AdjustmentFilter Inactive
    , CategoryFilter Inactive
    , PayeeFilter Inactive
    , SinceFilter Inactive
    ]


initialViewState : TransactionViewerViewState
initialViewState =
    { adjustmentDropdown = Dropdown.initialState
    , categoryDropdown = Dropdown.initialState
    , payeeDropdown = Dropdown.initialState
    }

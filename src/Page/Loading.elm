module Page.Loading exposing (..)

import Html exposing (..)
import Update
import Model exposing (LoadingType(..))


view : LoadingType -> Html Update.Msg
view loadingType =
    div []
        [ h2 [] [ text "I Would Have Saved..." ]
        , text (message loadingType)
        ]


message : LoadingType -> String
message loadingType =
    case loadingType of
        LoadingTransactions ->
            "Loading Transactions..."

        LoadingBudgets ->
            "Loading Budgets..."

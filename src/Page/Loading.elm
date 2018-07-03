module Page.Loading exposing (..)

import Html exposing (..)
import Update
import Model exposing (LoadingType(..))
import Styling
import Bootstrap.Progress as Progress
import Bootstrap.Utilities.Spacing as Spacing


view : LoadingType -> Html Update.Msg
view loadingType =
    div []
        [ Styling.title
        , Styling.row [ h5 [ Spacing.mt2 ] [ text (message loadingType) ] ]
        , Styling.row
            [ Progress.progress
                [ Progress.animated
                , Progress.value 100
                ]
            ]
        ]


message : LoadingType -> String
message loadingType =
    case loadingType of
        LoadingTransactions ->
            "Loading Transactions..."

        LoadingBudgets ->
            "Loading Budgets..."

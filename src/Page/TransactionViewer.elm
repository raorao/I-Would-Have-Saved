module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Update exposing (Msg)
import RemoteData exposing (RemoteData)
import TransactionReducer
import Http


view : Model.Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "I Would Have Spent" ]
        , viewSavings model.transactions
        ]


viewSavings : RemoteData Http.Error (List Model.Transaction) -> Html Msg
viewSavings transactions =
    transactions
        |> RemoteData.withDefault []
        |> TransactionReducer.savings
        |> toString
        |> text
        |> List.singleton
        |> div []

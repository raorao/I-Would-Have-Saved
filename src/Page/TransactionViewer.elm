module Page.TransactionViewer exposing (..)

import Model
import Html exposing (..)
import Update exposing (Msg)
import RemoteData exposing (RemoteData)
import Http


view : Model.Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "I Would Have Spent" ]
        , viewTransactions model.transactions
        ]


viewTransactions : RemoteData Http.Error (List Model.Transaction) -> Html Msg
viewTransactions transactions =
    transactions
        |> RemoteData.withDefault []
        |> List.map viewTransaction
        |> div []


viewTransaction : Model.Transaction -> Html Msg
viewTransaction transaction =
    div []
        [ text ("  category " ++ transaction.category)
        , text ("  amount" ++ toString transaction.amount)
        ]

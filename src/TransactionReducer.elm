module TransactionReducer exposing (savings)

import Model exposing (..)


savings : List Transaction -> Float
savings transactions =
    transactions
        |> List.map .amount
        |> List.sum
        |> format


format : Int -> Float
format amount =
    (toFloat amount) / 1000.0

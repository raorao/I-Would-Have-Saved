module TransactionReducer exposing (savings, categories)

import Model exposing (..)
import List.Extra
import Date.Extra.Compare as DateCompare


savings : Filters -> List Transaction -> Float
savings filters transactions =
    transactions
        |> List.filter (applySince filters.since)
        |> List.filter (applyCategory filters.category)
        |> List.map .amount
        |> List.sum
        |> toFloat
        |> applyAdjustment filters.adjustment
        |> toDollars


categories : List Transaction -> List String
categories transactions =
    transactions
        |> List.map .category
        |> List.filterMap identity
        |> List.Extra.unique
        |> List.sort


applyAdjustment : Maybe Adjustment -> Float -> Float
applyAdjustment adjustment currentSavings =
    case adjustment of
        Just (Adjustment val) ->
            val * currentSavings

        Nothing ->
            currentSavings


toDollars : Float -> Float
toDollars amount =
    -amount / 1000.0


applyCategory : Maybe CategoryFilter -> Transaction -> Bool
applyCategory categoryFilter transaction =
    let
        matches (CategoryFilter filterCategory) transactionCategory =
            filterCategory == transactionCategory
    in
        Maybe.map2 matches categoryFilter transaction.category
            |> Maybe.withDefault False


applySince : Maybe SinceFilter -> Transaction -> Bool
applySince sinceFilter transaction =
    case sinceFilter of
        Just (SinceFilter since) ->
            DateCompare.is
                DateCompare.SameOrAfter
                transaction.date
                since

        Nothing ->
            True

module TransactionReducer exposing (savings, categories)

import Model exposing (..)
import List.Extra
import Date.Extra.Compare as DateCompare


savings : Filters -> List Transaction -> String
savings filters transactions =
    transactions
        |> List.filter (applySince filters.since)
        |> List.filter (applyCategory filters.category)
        |> List.map .amount
        |> List.sum
        |> toFloat
        |> applyAdjustment filters.adjustment
        |> format


categories : List Transaction -> List String
categories transactions =
    transactions
        |> List.map .category
        |> List.Extra.unique
        |> List.sort


applyAdjustment : Maybe Adjustment -> Float -> Float
applyAdjustment adjustment currentSavings =
    case adjustment of
        Just (Adjustment val) ->
            val * currentSavings

        Nothing ->
            currentSavings


format : Float -> String
format amount =
    let
        inDollars =
            -amount / 1000.0
    in
        "$" ++ (toString inDollars)


applyCategory : Maybe CategoryFilter -> Transaction -> Bool
applyCategory categoryFilter transaction =
    case categoryFilter of
        Just (CategoryFilter category) ->
            transaction.category == category

        Nothing ->
            False


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

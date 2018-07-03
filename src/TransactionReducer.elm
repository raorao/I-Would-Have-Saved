module TransactionReducer exposing (savings, categories, payees)

import Model exposing (..)
import List.Extra
import Date.Extra.Compare as DateCompare


savings : Filters -> List Transaction -> Float
savings filters transactions =
    transactions
        |> List.filter (applySince filters.since)
        |> List.filter (applyCategory filters.category)
        |> List.filter (applyPayee filters.payee)
        |> List.filter (.category >> isVisibleCategory)
        |> List.map .amount
        |> List.sum
        |> toFloat
        |> applyAdjustment filters.adjustment
        |> toDollars


categories : List Transaction -> List String
categories transactions =
    transactions
        |> List.map .category
        |> List.filter isVisibleCategory
        |> List.filterMap identity
        |> List.Extra.unique
        |> List.sort


payees : List Transaction -> List String
payees transactions =
    transactions
        |> List.map .payee
        |> List.filterMap identity
        |> List.Extra.unique
        |> List.sort


isVisibleCategory : Maybe String -> Bool
isVisibleCategory category =
    case category of
        Just "Immediate Income SubCategory" ->
            False

        Just "Split (Multiple Categories)..." ->
            False

        Just _ ->
            True

        Nothing ->
            True


applyAdjustment : Filter AdjustmentFilter -> Float -> Float
applyAdjustment adjustment currentSavings =
    case adjustment of
        Active TenPercent ->
            0.1 * currentSavings

        Active TwentyFivePercent ->
            0.25 * currentSavings

        Active HalfAsMuch ->
            0.5 * currentSavings

        Active NothingAtAll ->
            1.0 * currentSavings

        Inactive ->
            currentSavings


toDollars : Float -> Float
toDollars amount =
    -amount / 1000.0


applyCategory : Filter CategoryFilter -> Transaction -> Bool
applyCategory categoryFilter transaction =
    case categoryFilter of
        Inactive ->
            True

        Active (CategoryFilter category) ->
            transaction.category
                |> Maybe.map ((==) category)
                |> Maybe.withDefault False


applyPayee : Filter PayeeFilter -> Transaction -> Bool
applyPayee payeeFilter transaction =
    case payeeFilter of
        Inactive ->
            True

        Active (PayeeFilter payee) ->
            transaction.payee
                |> Maybe.map ((==) payee)
                |> Maybe.withDefault False


applySince : Filter SinceFilter -> Transaction -> Bool
applySince sinceFilter transaction =
    case sinceFilter of
        Active (SinceFilter since) ->
            DateCompare.is
                DateCompare.SameOrAfter
                transaction.date
                since

        Inactive ->
            True

module TransactionReducer exposing (savings, categories, payees, isBetweenDates)

import Model exposing (..)
import List.Extra
import Date exposing (Date)
import Date.Extra.Compare as DateCompare


applyFilter : FilterType -> Transaction -> Bool
applyFilter filterType transaction =
    case filterType of
        CategoryFilter category ->
            True

        PayeeFilter payee ->
            True

        SinceFilter since ->
            True

        AdjustmentFilter val ->
            True


savings : List FilterType -> List Transaction -> Float
savings filterTypes transactions =
    filterTypes
        |> List.foldr (List.filter applyFilter) transactions
        |> List.filter (.category >> isVisibleCategory)
        |> List.map .amount
        |> List.sum
        |> toFloat
        |> toDollars


categories : List FilterType -> List Transaction -> List String
categories filters transactions =
    transactions
        |> List.filter (applyPayee filters.payee)
        |> List.filter (applySince filters.since)
        |> List.map .category
        |> List.filter isVisibleCategory
        |> List.filterMap identity
        |> List.Extra.unique
        |> List.sort


payees : List FilterType -> List Transaction -> List String
payees filters transactions =
    transactions
        |> List.filter (applyCategory filters.category)
        |> List.filter (applySince filters.since)
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


applyAdjustment : AdjustmentFilterVal -> Float -> Float
applyAdjustment adjustment currentSavings =
    case adjustment of
        TenPercent ->
            0.1 * currentSavings

        TwentyFivePercent ->
            0.25 * currentSavings

        HalfAsMuch ->
            0.5 * currentSavings


toDollars : Float -> Float
toDollars amount =
    -amount / 1000.0


applyCategory : String -> Transaction -> Bool
applyCategory category transaction =
    transaction.category
        |> Maybe.map ((==) category)
        |> Maybe.withDefault False


applyPayee : String -> Transaction -> Bool
applyPayee payee transaction =
    transaction.payee
        |> Maybe.map ((==) payee)
        |> Maybe.withDefault False


applySince : Date -> Transaction -> Bool
applySince since transaction =
    DateCompare.is
        DateCompare.SameOrAfter
        transaction.date
        since


isBetweenDates : List Transaction -> Date -> Bool
isBetweenDates transactions date =
    let
        sorter date1 date2 =
            if (DateCompare.is DateCompare.SameOrAfter date1 date2) then
                GT
            else
                LT

        sortedDates =
            transactions
                |> List.map .date
                |> List.sortWith sorter

        first =
            List.head sortedDates

        last =
            List.Extra.last sortedDates

        dateComparator min max =
            DateCompare.is3 DateCompare.BetweenOpen date min max
    in
        Maybe.map2 dateComparator first last
            |> Maybe.map not
            |> Maybe.withDefault False

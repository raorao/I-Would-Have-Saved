module Main exposing (..)

import Html exposing (Html, text, div, h1, a)
import Html.Attributes exposing (href)


---- MODEL ----


type alias Config =
    { ynab_client_id : String, ynab_redirect_uri : String }


type alias Model =
    { config : Config }


init : Config -> ( Model, Cmd Msg )
init config =
    ( { config = config }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


ynabURL : Config -> String
ynabURL { ynab_client_id, ynab_redirect_uri } =
    "https://app.youneedabudget.com/oauth/authorize?client_id="
        ++ ynab_client_id
        ++ "&redirect_uri="
        ++ ynab_redirect_uri
        ++ "&response_type=token"


view : Model -> Html Msg
view model =
    div [] [ a [ href (ynabURL model.config) ] [ text "Login to YNAB" ] ]



---- PROGRAM ----


main : Program Config Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }

module View exposing (view)

import Html exposing (Html, text, div, h1, a)
import Html.Attributes exposing (href)
import Model exposing (PageModel(..), Model, Config)
import Update exposing (Msg)


ynabURL : Config -> String
ynabURL { ynab_client_id, ynab_redirect_uri } =
    "https://app.youneedabudget.com/oauth/authorize?client_id="
        ++ ynab_client_id
        ++ "&redirect_uri="
        ++ ynab_redirect_uri
        ++ "&response_type=token"


viewLoggedOut : Model -> Html Msg
viewLoggedOut model =
    div [] [ a [ href (ynabURL model.config) ] [ text "Login to YNAB" ] ]


viewLoggedIn : Model -> Html Msg
viewLoggedIn model =
    text "you're logged in!"


view : Model -> Html Msg
view model =
    case model.pageModel of
        LoggedOut ->
            viewLoggedOut model

        LoggedIn _ ->
            viewLoggedIn model

        Error ->
            text "uh oh"

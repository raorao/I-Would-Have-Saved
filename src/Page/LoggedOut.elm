module Page.LoggedOut exposing (..)

import Model
import Html exposing (..)
import Html.Attributes exposing (href)
import Update
import Model
import Bootstrap.Button as Button
import Bootstrap.Utilities.Spacing as Spacing
import Styling
import Bootstrap.Grid.Col as Col
import Bootstrap.Text as Text


view : Model.Config -> Html Update.Msg
view config =
    div []
        [ Styling.title
        , Styling.row
            [ Button.linkButton
                [ Button.info, Button.large, Button.attrs [ href (ynabURL config), Spacing.mb5, Spacing.mt3 ] ]
                [ text "Login to YNAB" ]
            ]
        , Styling.rowWithColOptions [ Col.textAlign Text.alignXsLeft ]
            [ p []
                [ b [] [ text "I Would Have Saved " ]
                , text "helps you find out where your money is going. Using the power of your "
                , a [ href "https://www.youneedabudget.com/" ] [ text "You Need A Budget" ]
                , text " transaction history, you can figure out how, where, and when you're spending your money – and where you should cut back!"
                ]
            , p []
                [ text "By using this application, you consent to our "
                , a [ href "/privacy" ] [ text "privacy policy" ]
                , text "."
                ]
            , p []
                [ text "Made by "
                , a [ href "https://twitter.com/raorao_" ] [ text "@raorao" ]
                , text " for the "
                , a [ href "https://www.youneedabudget.com/contest-ynab-api/" ] [ text "YNAB API Contest" ]
                , text ". Source code available "
                , a [ href "http://github.com/raorao/I-Would-Have-Saved" ] [ text "on GitHub." ]
                ]
            ]
        ]


ynabURL : Model.Config -> String
ynabURL { ynab_client_id, ynab_redirect_uri } =
    "https://app.youneedabudget.com/oauth/authorize?client_id="
        ++ ynab_client_id
        ++ "&redirect_uri="
        ++ ynab_redirect_uri
        ++ "&response_type=token"

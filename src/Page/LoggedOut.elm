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


ynabURL : Model.Config -> String
ynabURL { ynab_client_id, ynab_redirect_uri } =
    "https://app.youneedabudget.com/oauth/authorize?client_id="
        ++ ynab_client_id
        ++ "&redirect_uri="
        ++ ynab_redirect_uri
        ++ "&response_type=token"


view : Model.Config -> Html Update.Msg
view config =
    div []
        [ Styling.title
        , Styling.row
            [ Button.linkButton
                [ Button.info, Button.large, Button.attrs [ href (ynabURL config), Spacing.mb5 ] ]
                [ text "Login to YNAB" ]
            ]
        , Styling.rowWithColOptions [ Col.textAlign Text.alignXsLeft ]
            [ p [] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nam libero justo laoreet sit amet." ]
            , p [] [ text "Nec nam aliquam sem et tortor consequat id porta nibh. Non blandit massa enim nec dui nunc mattis. Id volutpat lacus laoreet non curabitur gravida. Lorem dolor sed viverra ipsum nunc aliquet bibendum. Nullam non nisi est sit amet facilisis." ]
            , p [] [ text "Tincidunt arcu non sodales neque. Libero justo laoreet sit amet." ]
            ]
        ]

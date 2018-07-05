module Page.PrivacyPolicy exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Update exposing (Msg)
import Styling
import Bootstrap.Grid.Col as Col
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing


view : Html Msg
view =
    div []
        [ Styling.title
        , Styling.row
            [ h3 [ Spacing.mb4 ] [ text "Privacy Policy" ] ]
        , Styling.rowWithColOptions [ Col.textAlign Text.alignXsLeft ]
            [ p []
                [ text "This policy applies to all information collected or submitted to I Would Have Saved."
                ]
            , h4 [] [ text "Information We Collect" ]
            , p []
                [ text "We currently do not collect any information from you or your You Need A Budget account. All data retrieved from YNAB (account credentials, transaction history) is stored in your browser, and is never transmitted to our servers. "
                ]
            , p []
                [ text "In the future, we may use cookies on the site and similar tokens in the app to keep you logged in. We may also collect aggregate, anonymous statistics, such as the percentage of users who use particular features, to improve the app. We may also store basic technical information, such as your IP address."
                ]
            , h4 [] [ text "Third-Party Sharing" ]
            , p []
                [ text "We will not distribute your personal information to outside parties without your consent."
                ]
            , h4 [] [ text "Your Consent" ]
            , p []
                [ text "By using our site, you consent to our privacy policy."
                ]
            , h4 [] [ text "Changes to This Policy" ]
            , p []
                [ text "If we decide to change our privacy policy, we will post those changes on this page. Summary of changes so far:"
                ]
            , ol []
                [ ul []
                    [ b [] [ text "July 5, 2018: " ]
                    , text "First published."
                    ]
                ]
            ]
        ]

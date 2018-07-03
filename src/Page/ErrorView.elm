module Page.ErrorView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (href)
import Model exposing (ErrorType(..))
import Update
import Styling
import Bootstrap.Alert as Alert


view : ErrorType -> Html Update.Msg
view error =
    div []
        [ Styling.title
        , Styling.row [ alert (parseError error) ]
        ]


parseError : ErrorType -> String
parseError errorType =
    case errorType of
        NoAccessToken ->
            "Could not find access token."

        ApiDown error ->
            let
                _ =
                    Debug.log "api error" error
            in
                "We're having trouble contacting YNAB."

        InvalidRoute ->
            "Something in your browser is funky."

        ImpossibleState ->
            "How did you get here?!?!"


alert : String -> Html Update.Msg
alert str =
    Alert.simpleDanger []
        [ text (str ++ " ")
        , Alert.link [ href "/" ] [ text "Try connecting to YNAB again." ]
        ]

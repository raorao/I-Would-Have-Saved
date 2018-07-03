module Styling exposing (..)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Text as Text
import Bootstrap.Utilities.Flex as Flex


row children =
    Grid.row
        [ Row.centerMd, Row.centerSm, (Row.attrs [ Flex.alignItemsCenter ]) ]
        [ Grid.col [ Col.lg6, Col.sm10, Col.textAlign Text.alignXsCenter ]
            children
        ]

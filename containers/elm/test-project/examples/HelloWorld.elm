module HelloWorld exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    String


init : Model
init =
    ""



-- UPDATE


type Msg
    = ToggleText


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleText ->
            if model == "" then
                "Hello World!"

            else
                ""



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick ToggleText ] [ text "Toggle text" ]
        , div [] [ text model ]
        ]

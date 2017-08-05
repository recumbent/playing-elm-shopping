module Main exposing (..)

import Html exposing (Html, h1, text)


-- MODEL


type alias Model =
    String


model : Model
model =
    "Hello World!"



-- UPDATE


type Msg
    = NOOP


update : Msg -> Model -> Model
update msg model =
    case msg of
        NOOP ->
            model



-- VIEW


view : Model -> Html msg
view model =
    h1 [] [ text model ]



-- Stitch it all together


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }

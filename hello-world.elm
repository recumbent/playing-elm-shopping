module Main exposing (..)

import Html exposing (Html, h1, text, div, input, Attribute)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)


-- MODEL


type alias Model =
    { name : String
    }


model : Model
model =
    { name = "World!"
    }



-- UPDATE


type Msg
    = Change String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Change text ->
            { model | name = text }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ input [ placeholder "Name to greet", onInput Change ] []
            ]
        , h1 [] [ text ("Hello " ++ model.name) ]
        ]



-- Stitch it all together


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }

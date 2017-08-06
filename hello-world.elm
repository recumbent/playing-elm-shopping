module Main exposing (..)

import Html exposing (Html, h1, text, div, input, Attribute, button)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onInput, onClick)
import Json.Decode as Json


-- MODEL


type alias Model =
    { inputText : String
    , name : String
    }


model : Model
model =
    { inputText = ""
    , name = "World"
    }



-- UPDATE


type Msg
    = Change String
    | Update


update : Msg -> Model -> Model
update msg model =
    case msg of
        Change text ->
            { model | inputText = text }

        Update ->
            { model | name = model.inputText, inputText = "" }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ input
                [ placeholder "Name to greet"
                , onInput Change
                , onEnter Update
                , value model.inputText
                ]
                []
            ]
        , button [ onClick Update ] [ text "Update" ]
        , h1 [] [ text ("Hello " ++ model.name ++ "!") ]
        ]



-- Borrowed from https://github.com/evancz/elm-todomvc/blob/master/Todo.elm


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not ENTER"
    in
        on "keydown" (Json.andThen isEnter keyCode)



-- Stitch it all together


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }

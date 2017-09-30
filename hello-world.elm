module Main exposing (..)

import Html exposing (Html, h1, text, div, input, Attribute, button, ul, li)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onInput, onClick)
import Json.Decode as Json

-- MODEL

type alias Item = 
    { id : Int
    , name : String
    , required : Bool
    }

type alias Model =
    { inputText : String
    , items : List Item
    }


model : Model
model =
    { inputText = ""
    , items = []
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
            let
                maxId = Maybe.withDefault 0 (List.maximum (List.map (\i -> i.id) model.items))
            in
                { model | items = (Item (maxId + 1) model.inputText True) :: model.items, inputText = "" }


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ input
                [ placeholder "Value to add"
                , onInput Change
                , onEnter Update
                , value model.inputText
                ]
                []
            ]
        , button [ onClick Update ] [ text "add" ]
        , h1 [] [ text ("A list of items!") ]
        , itemsView (matchingItems model)
        ]

itemsView : List { c | id : a, name : String, required : b } -> Html msg
itemsView items =
     ul [] (List.map itemView items)

itemView : { c | id : a, name : String, required : b } -> Html msg
itemView item =
    li [] [ text ((toString item.id) ++ " " ++ item.name ++ " " ++ (toString item.required)) ]

matchingItems : { b | inputText : String, items : List { a | name : String } } -> List { a | name : String }
matchingItems model =
    List.filter (\item -> String.contains (String.toLower model.inputText) (String.toLower item.name)) model.items

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

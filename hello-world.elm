module Main exposing (..)

import Html exposing (Html, h1, h2, text, div, input, Attribute, button, ul, li, table, thead, tr, th, tbody, td)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onInput, onClick, onCheck)
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
    | ToggleRequired Int Bool

update : Msg -> Model -> Model
update msg model =
    case msg of
        Change text ->
            { model | inputText = text }

        Update ->
            case List.head (matchingItems model.inputText model.items) of
                Just item ->
                    { model | items = (setItemRequired item.id True model.items), inputText = "" }

                Nothing ->
                    let
                        maxId = Maybe.withDefault 0 (List.maximum (List.map (\i -> i.id) model.items))
                    in
                        { model | items = List.sortBy .name ((Item (maxId + 1) model.inputText True) :: model.items), inputText = "" }

        ToggleRequired id state ->
            { model | items = setItemRequired id state model.items }


setItemRequired : Int -> Bool -> List Item -> List Item
setItemRequired id state items =
    List.map (\i -> if i.id == id then { i | required = state } else i) items

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
        , h2 [] [ text ("Items required: " ++ (toString (List.length (List.filter (\i -> i.required) model.items)))) ]
        , itemsView (matchingItems model.inputText model.items)
        ]

itemsView : List Item -> Html Msg
itemsView items =
    table []
        [ thead []
            [
                tr []
                    [ th [] [ text "ID" ]
                    , th [] [ text "Item Name" ]
                    , th [] [ text "Required?" ]
                    ]
            ]
        , tbody [] (List.map itemView items)
        ]

itemView : Item -> Html Msg
itemView item =
    tr [] 
        [ td [] [ text (toString item.id) ]
        , td [] [ text item.name ]
        , td [] [ input [ type_ "checkbox", (checked item.required), onCheck (ToggleRequired item.id) ] [] ]
        ]

matchingItems : String -> List { a | name : String } -> List { a | name : String }
matchingItems textToMatch items =
    List.filter (\item -> String.contains (String.toLower textToMatch) (String.toLower item.name)) items

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

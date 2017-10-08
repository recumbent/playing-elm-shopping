module Main exposing (..)

import Html exposing (Html, h1, h2, text, div, input, Attribute, button, ul, li, table, thead, tr, th, tbody, td)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onInput, onClick, onCheck)
import Json.Decode as Json
import RemoteData exposing (..)
import Http exposing (Error)

-- MODEL

type alias Item = 
    { id : Int
    , name : String
    , required : Bool
    }

type alias ItemList = List Item

type alias Model =
    { inputText : String
    , items : RemoteData Error ItemList
    }

model : Model
model =
    { inputText = ""
    , items = Loading
    }

init : String -> (Model, Cmd Msg)
init  =
  ( model
  , getItemList
  )


-- COMMAND

-- HTTP
getNews : Cmd Msg
getNews =
    Http.get "http://127.0.0.1:4000/items" decodeItems
        |> RemoteData.sendRequest
        |> Cmd.map ItemsResponse


-- UPDATE


type Msg
    = Change String
    | Update
    | ToggleRequired Int Bool
    | ItemsResponse (RemoteData Error ItemList)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Change text ->
            { model | inputText = text }

        Update ->
            case model.items of
                Success itemList ->
                    case List.head (matchingItems model.inputText itemList) of
                        Just item ->
                            { model | items = Success (setItemRequired item.id True itemList), inputText = "" }

                        Nothing ->
                            let
                                maxId = Maybe.withDefault 0 (List.maximum (List.map (\i -> i.id) itemList))
                            in
                                { model | items = Success (List.sortBy .name ((Item (maxId + 1) model.inputText True) :: itemList)), inputText = "" }
                _ -> model

        ToggleRequired id state ->
            case model.items of
                Success itemList ->
                    { model | items = Success (setItemRequired id state itemList) }
                
                _ ->
                    model

setItemRequired : Int -> Bool -> List Item -> List Item
setItemRequired id state items =
    List.map (\i -> if i.id == id then { i | required = state } else i) items

-- VIEW


view : Model -> Html Msg
view model =
    case model.items of
        NotAsked ->
            div []
                [ h1 [] [ text "Should never see this" ] ]

        Loading ->
            div []
                [ h1 [] [ text "Loading items..." ] ]
            
        Failure err ->
            div []
                [ h1 [] [ text ("HTTP Failure" ++ (toString err)) ] ]
        
        Success items ->
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
                , h2 [] [ text ("Items required: " ++ (toString (List.length (List.filter (\i -> i.required) items)))) ]
                , itemsView (matchingItems model.inputText items)
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

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = Sub.none
    }
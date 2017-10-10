module Main exposing (..)

import Html exposing (Html, h1, h2, text, div, input, Attribute, button, ul, li, table, thead, tr, th, tbody, td)
import Html.Attributes exposing (..)
import Html.Events exposing (keyCode, on, onInput, onClick, onCheck)
import Json.Decode as Json
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
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

init : (Model, Cmd Msg)
init  =
  ( model
  , getItemList
  )


-- COMMAND

getItemList : Cmd Msg
getItemList =
    Http.get "http://127.0.0.1:4000/items" decodeItems
        |> RemoteData.sendRequest
        |> Cmd.map ItemsResponse

decodeItems : Json.Decoder (List Item)
decodeItems =
    (Json.list itemDecoder)

itemDecoder : Json.Decoder Item
itemDecoder =
    Pipeline.decode Item 
    |> Pipeline.required "id" Json.int
    |> Pipeline.required "name" Json.string
    |> Pipeline.required "required" Json.bool

itemUrl : a -> String
itemUrl id = 
    "http://127.0.0.1:4000/items/" ++ (toString id)

setItemStateRequest : a -> Bool -> Http.Request Item
setItemStateRequest id state =
    Http.request
        { body = itemStateEncoder state |> Http.jsonBody
        , expect = Http.expectJson itemDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = itemUrl id
        , withCredentials = False
        }

itemStateEncoder : Bool -> Encode.Value
itemStateEncoder required =
    let
        attributes = 
            [ ("required", Encode.bool required ) ]
    in
        Encode.object attributes
        
setItemStateCmd : a -> Bool -> Cmd Msg
setItemStateCmd id state =
    setItemStateRequest id state
    |> RemoteData.sendRequest
    |> Cmd.map OnSetItemState

newItemRequest item =
    let
        itemBody = itemEncoder item |> Http.jsonBody
    in
        Http.post "http://127.0.0.1:4000/items"  itemBody itemDecoder

itemEncoder item =
    let
        attributes =
            [ ( "id", Encode.int item.id )
            , ( "name", Encode.string item.name )
            , ( "required", Encode.bool item.required )
            ]
    in
        Encode.object attributes


newItemCmd item =
    newItemRequest item
    |> RemoteData.sendRequest
    |> Cmd.map OnNewItem

-- UPDATE


type Msg
    = Change String
    | Update
    | ToggleRequired Int Bool
    | ItemsResponse (RemoteData Error ItemList)
    | OnSetItemState (RemoteData Error Item)
    | OnNewItem (RemoteData Error Item)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Change text ->
            ({ model | inputText = text }, Cmd.none)

        Update ->
            case model.items of
                Success itemList ->
                    case List.head (matchingItems model.inputText itemList) of
                        Just item ->
                            ({ model | items = Success (setItemRequired item.id True itemList), inputText = "" }, (setItemStateCmd item.id True))

                        Nothing ->
                            let
                                maxId = Maybe.withDefault 0 (List.maximum (List.map (\i -> i.id) itemList))
                                nextId = maxId + 1
                                newItem = Item nextId model.inputText True
                            in
                                ({ model | items = Success (sortItemsForList (newItem :: itemList)), inputText = "" }, newItemCmd newItem)
                _ -> (model, Cmd.none)

        ToggleRequired id state ->
            case model.items of
                Success itemList ->                    
                    ({ model | items = Success (setItemRequired id state itemList) }, (setItemStateCmd id state))
                
                _ ->
                    (model, Cmd.none)
                    
        ItemsResponse rd ->
            let
                itemData = case rd of
                    Success itemList -> Success (sortItemsForList itemList)
                    _ -> rd
            in
                ({ model | items = itemData}, Cmd.none)

        OnSetItemState rd ->
            (model, Cmd.none)

        OnNewItem rd ->
            (model, Cmd.none)
        
setItemRequired : Int -> Bool -> List Item -> List Item
setItemRequired id state items =
    List.map (\i -> if i.id == id then { i | required = state } else i) items

sortItemsForList : List { a | name : comparable } -> List { a | name : comparable }
sortItemsForList =
    List.sortBy .name
    
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
                [ h1 [] [ text ("HTTP Failure: " ++ (toString err)) ] ]
        
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
    , subscriptions = \_ -> Sub.none
    }

# 007 - Prettier

First thing is to lay the items out as a table, we'll need to pull a lot more html in

```elm
import Html exposing (Html, h1, text, div, input, Attribute, button, ul, li, table, thead, tr, th, tbody, td)
```

Then we rewrite the two item functions

```elm
itemsView : List { c | id : a, name : String, required : b } -> Html msg
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
        ,   tbody [] (List.map itemView items)
        ]

itemView : { c | id : a, name : String, required : b } -> Html msg
itemView item =
    tr [] 
        [ td [] [ text (toString item.id) ]
        , td [] [ text item.name ]
        , td [] [ text (toString item.required) ]
        ]
```

Nothing else changes and it all just works - fairly standard template stuff but all implemented as functions (and in theory testable as such)

Actually that's still not quite right... that "required" should really be a checkbox

```elm
        , td [] [ input [ type_ "checkbox", (checked item.required) ] [] ]
```

Better - but that checkbox doesn't actually do anything, its just for show and worse if we do click on it nothing happens. Lets wire it up so that it updates the model

Add `onCheck` to the Html.Events

Add `| ToggleRequired Int Bool` to the Msg 

Then we add the event to the attributes for the checkbox

```elm
    , td [] [ input [ type_ "checkbox", (checked item.required), onCheck (ToggleRequired item.id) ] [] ]
```

Sadly this messes up our function signatures - we have to be more explicit so lets go all the way with that and we end up with

```elm
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
        ,   tbody [] (List.map itemView items)
        ]

itemView : Item -> Html Msg
itemView item =
    tr [] 
        [ td [] [ text (toString item.id) ]
        , td [] [ text item.name ]
        , td [] [ input [ type_ "checkbox", (checked item.required), onCheck (ToggleRequired item.id) ] [] ]
        ]
```

At this point we have red squigglies all over the update function - we haven't done anything with the ToggleRequired message

If we get a toggle message then we map over the items - and set `required` to match the state of the textbox

```elm
    ToggleRequired id state ->
      { model | items = List.map (\i -> if i.id == id then { i | required = state } else i) model.items }
```

If I'm honest - remembering that particular trick, running a map over a list to get a new list with a single item changed is one that I have to work hard to remember but it reflects the immutable nature of functional languages.

Just to show that this is working lets add a count of the required items. Put this after the h1:

```elm
    , h2 [] [ text ("Items required: " ++ (toString (List.length (List.filter (\i -> i.required) model.items)))) ]
```

# 004 - List the things

So lets start to drift towards something that might be useful.

Instead of just showing the latest value, lets add it to a list (and display the list...)

So the first thing we need to do is change the model:

```elm
type alias Model =
    { inputText : String
    , items : List String
    }
```

And therefore we have to change our initialisation:

```elm
model =
    { inputText = ""
    , items = []
    }
```

So we're replaced name with items and initialised the list to be empty.

Now we need to change our view to show the list of items:

```elm
        , button [ onClick Update ] [ text "add" ]
        , h1 [] [ text ("A list of items!") ]
        , ul [] (List.map (\i -> li [] [ text i ]) model.items)
```

Change the button remove the dynamic element from the h1 and then... well this is where the fun starts.

We want an unordered list (at this point) with an item for each element in the list - so we add a ul and then map the elements in the list to an li using an annonymous function. Lets break that down a bit more:

The `\` indicates an anonymous function, the i is the item - which in this case is a string. li is a function of the form `List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg` there are no attributes, the content is a list containing just the string (text has the form `String -> Html.Html msg`

```elm
\i -> li [] [ text i ]
```

Expanding out from there List.map takes a function and applies it to a list (in this case model.items which is a list of strings) - so this converts the list of items into a list of html elements (with the msg again, no I don't know either...) 

```elm
List.map (\i -> li [] [ text i ]) model.items
```

Finally we have a ul and we give it the mapped values as its "content"

```elm
        , ul [] (List.map (\i -> li [] [ text i ]) model.items)
```

So if there is a list of items we'll see them...

Which brings us to adding things. The key here being a small change to the update function - here we simply add the text to the front of the list using `::` note that this is a -> List a -> List a - so the new element has to come first.

```elm
{ model | items = model.inputText :: model.items, inputText = "" }
```

So we've got a list we can add to dynamically.




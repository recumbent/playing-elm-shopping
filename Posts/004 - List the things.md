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

We want an unordered list (at this point) with an item for each element in the list - so we add a ul and then map the elements in the list to an li using an annonymous function 


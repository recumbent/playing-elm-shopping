# 005 - Filtered Items

This is being done to a purpose, so the next thing is to only show items that match the text typed - in due course we're going to have a notion of match or add.

For now (possibly forever) lets treat this as a display issue - so all we need to do is to change the view.

To simplify things we'll add a helper function:

```elm
matchingItems : { a | inputText : String, items : List String } -> List String
matchingItems model =
    List.filter (\item -> String.contains (String.toLower model.inputText) (String.toLower item)) model.items
```

So if the item (which is currently a string) contains the input text we want to include it in the list - the function as a whole maps a simple filter.

Then in the view we replace model.items with the filtered versioh:

```elm
  , ul [] (List.map (\i -> li [] [ text i ]) (matchingItems model))
```

So now we map just the matching items into the list - and we're done.
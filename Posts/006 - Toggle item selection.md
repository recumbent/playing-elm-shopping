# 006 - Toggle item selection

Clearly there's a purpose to the changes that have been made, the next step is to be a bit more explicit about selection

We'll start by making the item a bit more interesting we'll give it an id and a "required" flag:

```elm
type alias Item = 
    { id : Int
    , name : String
    , required : Bool
    }
```

Then we'll change the type of items in the model

```elm
   , items : List item
```

That should cause a few things to break...

First thing that's broken is the update - we now need to add a new item setting its id (and marking it required) since a type alias has a constructor by default our first pass at an update becomes:

```elm
    { model | items = (Item 1 model.inputText True) :: model.items, inputText = "" }
```

That leaves us with the view to fix and the first problem is that our matchingItems function has a type error

To fix that we make a small change to the function by changing `item` to `item.name` which also changes the function signature giving:

```elm
matchingItems : { b | inputText : String, items : List { a | name : String } } -> List { a | name : String }
matchingItems model






    List.filter (\item -> String.contains (String.toLower model.inputText) (String.toLower item.name)) model.items
```

The function signature is a bit long winded at this point but it shows us an interesting thing about the type system and the generic nature of things

I think we need a better layout...

Lets move the model for the items into its own function

```elm
itemsView items =
     ul [] (List.map (\i -> li [] [ text i.name ]) items)
```

And change the main view

```elm
        , itemsView (matchingItems model)
```

Which also separates selection from the rendering of the items. Speaking of which we're now lacking a bit of information - so lets render up a bit more

So change the methods again

```elm
itemsView items =
     ul [] (List.map itemView items)

itemView item =
    li [] [ text ((toString item.id) ++ " " ++ item.name ++ " " ++ (toString item.required)) ]
```

And now we get a list of items with their Id and whether they're required. Its not pretty but it works and that shows us another problem, all the items have the same id...

Firstly we'll sort out the id:

```elm
    let
        maxId = Maybe.withDefault 0 (List.maximum (List.map (\i -> i.id) model.items))
    in
        { model | items = (Item (maxId + 1) model.inputText True) :: model.items, inputText = "" }
```

The maxId is either 0 if the list is empty (List.maximum will return a Maybe valued "nothing") or is the max value from the list.

Ok... more changes should be a new commit


# 008 - A little more polish

We're starting to get somewhere useful, but the order the items are displayed in is a mess - we add them to the start of the list and really they ought to be sorted, probably by name.

We have two choices:

1. We can sort by Id
1. We can sort by the item name

Id is really just there for convenience and in the real world we wouldn't show the value. That leaves the name and for that we have two choices - we could sort when we display the data or we could sort when we add the value. For performance reasons it seems better (to me) to sort when we add

So lets change the update to do that:

```elm
    { model | items = List.sortBy .name ((Item (maxId + 1) model.inputText True) :: model.items), inputText = "" }
```

So that was easy! All we do is sort... so now we can see what happens if we add the same item twice. Eeeuuuhh

If the item we add already exists we don't want to add it again, we just want to set it to required, if more than one item matches we'll use the first (for now)

Firstly is the item in the list? Well we already have a matching items function

We'll refactor that a bit because we don't really want to pass in the whole model

```elm
matchingItems : String -> List { a | name : String } -> List { a | name : String }
matchingItems textToMatch items =
    List.filter (\item -> String.contains (String.toLower textToMatch) (String.toLower item.name)) items
```

Now we can use this to see if we've got a matching item

```elm
    case List.head (matchingItems model.inputText model.items) of
```

If we do have a matching item then we want to return the items list with required set to true for that item - we do this already so lets pull out a function (we're being pretty specific about the signature because interesting things happen if we don't)

```elm
setItemRequired :  Int -> Bool -> List Item -> List Item
setItemRequired id state items =
    List.map (\i -> if i.id == id then { i | required = state } else i) items
```

If there is no matching item then we do the same as before, add a new item and sort the list - so the code for that doesn't change.

Finally we change the ToggleRequired code to use the , the whole update ends up looking like this:

```elm
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
```
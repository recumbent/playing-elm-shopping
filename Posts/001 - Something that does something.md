# Something that does something

In theory now we have the ability to actually write some code - and the best way to learn is try (and possibly fail) so lets progress to some form of hello world.

So lets have an objective in two parts that will let us see a running "application":

1. Render hello world
1. Text box -> button -> hello contents of text box

So lets write something fairly close to a minimal program

First thing we need are some dependencies

```
import Html exposing (Html, h1, text)
```

We want to import from the Elm Html package, we're pulling in Html which provides everything and then explicity h1 and text which we need to render something

Next we need a model - that which represents the state.

```
-- MODEL
type alias Model = String

model : Model
model = "Hello World!"
```

For this example we don't actually need the model, but we're going to want one for anything useful so we may as well start with one

Next we'll define the update function - again not using this for this example so its just a no-op

```
-- UPDATE
type Msg = NOOP

update msg model =
    case msg of
        NOOP -> model
```

So in this case the update function returns the model unmodified

Finally we want a view function

```
-- VIEW
view model =
    h1 [] [text model]
```

Which takes the model and returns us an h1 tag with the model rendered as text

Given all the above we can now create a program

```
-- Stitch it all together
main = 
    Html.beginnerProgram { model = model, view = view, update = update }
```

So the program takes a model, a view function and an update function and then knows how to run them.

You'll want to .gitignore the elm-stuff folder at this point!
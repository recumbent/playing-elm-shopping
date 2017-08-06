# 002 = A little interaction

There's not a lot of point in having 40 odd lines of code to replace a single line of markup, but if that's all we wanted we wouldn't need javascript either.

So lets add some interaction - a text box...

First lets make the model a little more structured

```
model : Model
model =
    { name = "World!" }
```

That requires that we change the view function too, lets fix the prefix too:

```
view : Model -> Html msg
view model =
    h1 [] [ text ("Hello " ++ model.name) ]
```

At this point we're still doing the same thing as before - so lets add some input

```
view model =
    div []
        [ div []
            [ input [ placeholder "Name to greet", onInput Change ] []
            ]
        , h1 [] [ text ("Hello " ++ model.name) ]
        ]

```

We'll nest everything in a div, and have a new div that contains an input before the header line

That upsets things a bit because we haven't defined the attributes or onInput or what Change means

So first we need some more imports

```
import Html exposing (Html, h1, text, div, input, Attribute)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
```

Next we need to change the Message and the update function:

```
type Msg
    = Change String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Change text ->
            { model | name = text }
```

Now when we get the change message we will also get the new text and we use that to return a copy of the model with name set to the new value of text box

And that's it - now the text is dynamic
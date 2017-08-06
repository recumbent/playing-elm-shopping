# 003 - Slightly smarter interaction

That's nice but its not quite nice enough...

Realy I don't want the greeting to change every time the text in the box changes what I really want is for the greeting to change when I hit enter

So lets change the model:

```
type alias Model =
    { inputText : String
    , name : String
    }


model : Model
model =
    { inputText = ""
    , name = "World!"
    }
```

And extend the message

```
type Msg
    = Change String
    | Update
```

If we do that the update function will complain because we're missing a case - this is the joy of union type (discriminated unions in F#)

So we change the update function to reflect the behaviour we now want

```
update msg model =
    case msg of
        Change text ->
            { model | inputText = text }

        Update ->
            { model | name = model.inputText, inputText = "" }
```

So we have two actions

1. If the text changes we store the value
1. If we get the Update message change the text

Hmm, but we don't have any way to trigger that update message?

So lets add that to the view

```
view model =
    div []
        [ div []
            [ input
                [ placeholder "Name to greet"
                , onInput Change
                , value model.inputText
                ]
                []
            ]
        , button [ onClick Update ] [ text "Update" ]
        , h1 [] [ text ("Hello " ++ model.name) ]
        ]
```

Which in turn means adding to the events import

```
import Html.Events exposing (onInput, onClick)
```

So clicking the button updates the greeting

Better... but not quite best. So lets add some code to pick up pressing enter in the text box

```
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
```

This is a function that takes a Msg and returns an attribute and the Msg

The `let` is used to define a function `isEnter` that returns Json.succeed and the passed in msg if the code passed in is 13 i.e. enter

Note that nice closure! The `in` is where we use the function and Json.andThen does magic I'm not 100% with yet (but works)

So now we type and hit enter or click on the update button and things change clever!
# 010 - Load list from server

Up to this point our data is ephemeral - refresh the page and its gone. We need to fix this.

Given the simple server we've set up lets start by reading the data from the API on startup.

To do this we're going to introduce commands and a helper type, lets start by adding the helper:

`elm package install elm-lang/http`
`elm package install krisajenkins/remotedata`

And importing the package into our application

```elm
import RemoteData exposing (..)
```

This gives us `RemoteData` and a specialsed case `WebData`.

We'll change the model, introducing some new type aliases

```elm
type alias ItemList = List Item

type alias Model =
    { inputText : String
    , items : WebData ItemList
    }


model : Model
model =
    { inputText = ""
    , items = Loading
    }
```

And add a new option to the message

Ok, all over the place here, need this: https://guide.elm-lang.org/interop/json.html

And then [NoRedInk/elm-decode-pipeline](http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/latest)

Then the party trick is to import Json.Decode and Json.Decode.Pipeline the latter lets us run the pipeline as below

```elm
itemDecoder = decode Item 
    |> required "id" int
    |> required "name" string
    |> required "required" bool
```

Which will let me decode a single item and can be combined with list...

```elm
decodeString (list itemDecode) itemsJson
```

Next step in the party games is to add a nullable aisle.

Then we need to write back to the "server"
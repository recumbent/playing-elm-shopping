# 010 - Load list from server

Up to this point our data is ephemeral - refresh the page and its gone. We need to fix this.

Given the simple server we've set up lets start by reading the data from the API on startup.

To do this we're going to introduce commands and a helper type, lets start by adding the helper:

` elm package install krisajenkins/remotedata`

And importing the package into our application

```elm
import RemoteData exposing (..)
```

This gives us `RemoteData` and a specialsed case `WebData`.

We'll change the model, introducing some new type aliases

```elm
type alias ItemList = List String

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
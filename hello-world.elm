import Html exposing (Html, h1, text)

-- MODEL
type alias Model = String

model : Model
model = "Hello World!"

-- UPDATE
type Msg = NOOP

update msg model =
    case msg of
        NOOP -> model

-- VIEW
view model =
    h1 [] [text model]

-- Stitch it all together
main = 
    Html.beginnerProgram { model = model, view = view, update = update }
 
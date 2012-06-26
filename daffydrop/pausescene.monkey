Strict

Private

Import mojo
Import bono

Public

Class PauseScene Extends Scene
    Method New()
        name = "pause"
    End

    Method OnCreate:Void()
        Local image:Sprite = New Sprite("pause.png")
        director.Center(image)
        layer.Add(image)
    End

    Method OnRender:Void()
        scenes.prevScene.OnRender()
        Super.OnRender()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Select event.code
        Case KEY_SPACE, KEY_ENTER, KEY_P
            scenes.Goto(scenes.prevScene)
        Default
            scenes.Goto("menu")
        End
    End

    Method OnTouchDown:Void(event:TouchEvent)
        scenes.Goto(scenes.prevScene)
    End
End

Strict

Private

Import mojo
Import bono

Public

Class IntroScene Extends Scene
    Private

    Field background:Sprite
    Field timer:Int

    Public

    Method New()
        name = "intro"
    End

    Method OnCreate:Void()
        background = New Sprite("logo.jpg")
        background.Center()
    End

    Method OnEnter:Void()
        timer = Millisecs() + 1500
    End

    Method OnUpdate:Void()
        If Millisecs() > timer Then CurrentDirector().scenes.Goto("menu")
    End

    Method OnRender:Void()
        Cls(255, 255, 255)
        background.OnRender()
    End
End

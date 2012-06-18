Strict

Private

Import mojo.graphics
Import mojo.app
Import bono.game
Import bono.scene
Import bono.sprite

Public

Class IntroScene Extends Scene
    Private

    Field background:Sprite
    Field timer:Int
    Const DURATION:Int = 1500

    Public

    Method New()
        name = "intro"
    End

    Method OnEnter:Void()
        background = New Sprite("logo.jpg")
        background.CenterGame()

        timer = Millisecs() + DURATION
    End

    Method OnUpdate:Void()
        If Millisecs() > timer Then CurrentGame().scenes.Goto("menu")
    End

    Method OnRender:Void()
        Cls(255, 255, 255)
        background.OnRender()
    End
End

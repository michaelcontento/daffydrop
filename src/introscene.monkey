Strict

Import mojo
Import bono

Class IntroScene Extends Scene
    Field background:Sprite
    Field timer:Int
    Const DURATION:Int = 1500

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

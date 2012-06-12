Strict

Import mojo.graphics
Import mojo.app

Import scene
Import game
Import sprite

Class IntroScene Extends Scene
    Field background:Sprite
    Field timer:Int
    Const DURATION:Int = 3000

    Method OnCreate:String()
        background = New Sprite("logo.jpg")
        background.CenterGame()

        Return "intro"
    End

    Method OnEnter:Void()
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

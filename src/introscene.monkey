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
        timer = Millisecs() + DURATION

        background = New Sprite("logo.jpg")
        background.x = CurrentGame().Width2() - background.Width2()
        background.y = CurrentGame().Height2() - background.Height2()

        Return "intro"
    End

    Method OnUpdate:Void()
        If Millisecs() > timer Then CurrentGame().scenes.Goto("menu")
    End

    Method OnRender:Void()
        Cls(255, 255, 255)
        background.OnRender()
    End
End

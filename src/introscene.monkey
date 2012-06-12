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

    Method New()
        name = "intro"
    End

    Method OnEnter:Void()
        background = Sprite("logo.jpg")
        background.x = (CurrentGame().Width() / 2) - (background.image.Width() / 2)
        background.y = (CurrentGame().Height() / 2) - (background.image.Height() / 2)
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

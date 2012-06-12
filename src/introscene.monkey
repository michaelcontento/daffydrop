Strict

Import mojo.graphics
Import mojo.app

Import scene
Import game

Class IntroScene Extends Scene
    Field background:Image
    Field timer:Int
    Const DURATION:Int = 3000

    Method New()
        name = "intro"
    End

    Method OnEnter:Void()
        background = LoadImage("logo.jpg")
        timer = Millisecs() + DURATION
    End

    Method OnUpdate:Void()
        If Millisecs() > timer Then CurrentGame().sceneManager.Goto("menu")
    End

    Method OnRender:Void()
        Local centerX:Int = (CurrentGame().Width() / 2) - (background.Width() / 2)
        Local centerY:Int = (CurrentGame().Height() / 2) - (background.Height() / 2)
        Cls(255, 255, 255)
        DrawImage(background, centerX, centerY)
    End
End

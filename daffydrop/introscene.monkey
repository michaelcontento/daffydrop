Strict

Private

Import mojo.graphics
Import bono
Import scene
Import appirater

Public

Class IntroScene Extends Scene
    Private

    Field background:Sprite
    Field timer:Int
    Const DURATION:Int = 1500

    Public

    Method OnCreate:Void(director:Director)
#If TARGET<>"ios"
        background = New Sprite("logo.jpg")
        layer.Add(background)
#End

        Super.OnCreate(director)

#If TARGET<>"ios"
        background.Center(director)
#End
    End

    Method OnEnter:Void()
        Appirater.Launched()
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
#If TARGET="ios"
        router.Goto("menu")
#Else
        If timer >= DURATION Then router.Goto("menu")
        timer += frameTime
#End
    End

    Method OnRender:Void()
        Cls(255, 255, 255)
        Super.OnRender()
    End
End

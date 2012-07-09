Strict

Private

Import bono
Import bono.vendor.angelfont
Import scene
Import gamehighscore

Public

Class HighscoreScene Extends Scene Implements RouterEvents
    Private

    Field background:Sprite
    Field highscore:GameHighscore = New GameHighscore()
    Field font:AngelFont

    Public

    Method OnCreate:Void(director:Director)
        font = New AngelFont("CoRa")

        background = New Sprite("highscore_bg.png")
        background.OnCreate(director)

        Super.OnCreate(director)
    End

    Method OnEnter:Void()
        StateStore.Load(highscore)
    End

    Method OnLeave:Void()
    End

    Method OnRender:Void()
        background.OnRender()
        PushMatrix()
            SetColor(255, 133, 0)
            Scale(1.5, 1.5)
            DrawEntries()
        PopMatrix()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        router.Goto("menu")
    End

    Method OnTouchDown:Void(event:TouchEvent)
        router.Goto("menu")
    End

    Private

    Method DrawEntries:Void()
        Local posY:Int = 190
        For Local score:Score<Int> = EachIn highscore
            font.DrawText(score.value, 100, posY, AngelFont.ALIGN_RIGHT)
            font.DrawText(score.key, 110, posY)
            posY += 35
        End
    End
End

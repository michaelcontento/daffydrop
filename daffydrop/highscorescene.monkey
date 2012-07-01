Strict

Private

Import bono
Import bono.vendor.angelfont

Public

Class HighscoreScene Extends Partial Implements RouterEvents
    Private

    Field background:Sprite
    Field highscore:IntHighscore = New IntHighscore(10)
    Field font:AngelFont

    Public

    Method OnCreate:Void(director:Director)
        font = New AngelFont("CoRa")
        background = New Sprite("highscore_bg.jpg")
        Super.OnCreate(director)
    End

    Method OnEnter:Void()
        StateStore.Load(highscore)
        PrefillMissing()
    End

    Method OnLeave:Void()
    End

    Method OnRender:Void()
        Super.OnRender()
        background.OnRender()
        PushMatrix()
            SetColor(255, 133, 0)
            Scale(1.5, 1.5)
            DrawEntries()
        PopMatrix()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        Router(director.handler).Goto("menu")
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Super.OnTouchDown(event)
        Router(director.handler).Goto("menu")
    End

    Private

    Method PrefillMissing:Void()
        While highscore.Count() < highscore.maxCount
            highscore.Add("..........", 0)
        End
    End

    Method DrawEntries:Void()
        Local posY:Int = 180
        For Local score:Score<Int> = EachIn highscore
            posY += 30
            font.DrawText(score.value, 130, posY, AngelFont.ALIGN_RIGHT)
            font.DrawText(score.key, 140, posY)
        End
    End
End

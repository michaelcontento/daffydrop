Strict

Private

Import bono

Public

Class HighscoreScene Extends Scene
    Private

    Field highscore:IntHighscore = New IntHighscore(10)
    Field font:AngelFont = New AngelFont()
    Field backButton:Sprite

    Public

    Method New()
        name = "highscore"
        font.LoadFont("CoRa")
    End

    Method OnCreate:Void()
        layer.Add(New Sprite("highscore_bg.jpg"))

        backButton = New Sprite("back.png")
        backButton.pos = CurrentDirector().size.Copy().Sub(backButton.size)
        layer.Add(backButton)
    End

    Method OnEnter:Void()
        highscore.Load()
        PrefillMissing()
    End

    Method OnRender:Void()
        Super.OnRender()

        PushMatrix()
            SetColor(255, 133, 0)
            Scale(1.5, 1.5)
            DrawEntries()
        PopMatrix()
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_B)
            CurrentDirector().scenes.Goto("menu")
        End
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If backButton.Collide(event.pos)
            CurrentDirector().scenes.Goto("menu")
        End
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

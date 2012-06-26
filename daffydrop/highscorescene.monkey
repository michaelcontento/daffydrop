Strict

Private

Import bono
Import bono.vendor.angelfont

Public

Class HighscoreScene Extends Scene
    Private

    Field highscore:IntHighscore = New IntHighscore(10)
    Field font:AngelFont
    Field backButton:Sprite

    Public

    Method New()
        name = "highscore"
    End

    Method OnCreate:Void()
        font = New AngelFont("CoRa")
        layer.Add(New Sprite("highscore_bg.jpg"))

        backButton = New Sprite("back.png")
        backButton.pos = director.size.Copy().Sub(backButton.size)
        layer.Add(backButton)
    End

    Method OnEnter:Void()
        StateStore.Load(highscore)
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
        If KeyDown(KEY_B) Then scenes.Goto("menu")
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If backButton.Collide(event.pos) Then scenes.Goto("menu")
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

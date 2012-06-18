Strict

Private

Import bono.angelfont
Import bono.game
Import bono.highscore
Import bono.scene
Import bono.score
Import bono.sprite

Public

Class HighscoreScene Extends Scene
    Private

    Field highscore:IntHighscore = New IntHighscore(10)
    Field font:AngelFont = New AngelFont()

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

    Public

    Method New()
        name = "highscore"
        font.LoadFont("angel_verdana")
    End

    Method OnCreate:Void()
        highscore.Load()
        PrefillMissing()
        layer.Add(New Sprite("highscore_bg.jpg"))
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
            CurrentGame().scenes.Goto("menu")
        End
    End
End

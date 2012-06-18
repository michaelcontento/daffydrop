Strict

Private

Import mojo
Import bono
Import severity

Public

Class Chute Implements Animationable
    Private

    Field bottom:Image
    Field severity:Severity

    Public

    Field height:Int = 50
    Field bg:Image

    Method New()
        bg = LoadImage("chute-bg.png")
        bottom = LoadImage("chute-bottom.png")
        severity = CurrentSeverity()
    End

    Method OnUpdate:Void()
        If severity.ChuteShouldAdvance()
            height += severity.ChuteAdvanceHeight()
            severity.ChuteMarkAsAdvanced()
        End
    End

    Method OnRender:Void()
        Local posX:Int
        For Local lane:Int = 0 To 3
            posX = 46 + (bg.Width() * lane)

            For Local posY:Int = 0 To height
                DrawImage(bg, posX, posY)
            End
            DrawImage(bottom, posX, height)
        End
    End
End

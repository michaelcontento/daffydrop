Strict

Import mojo
Import bono
Import severity

Class Chute Implements Animationable
    Field bottom:Image
    Field bg:Image
    Field height:Int = 50
    Field severity:Severity

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
        For Local lane:Int = 0 To 3
            For Local posY:Int = 0 To height
                DrawImage(bg, bg.Width() * lane, posY)
            End

            DrawImage(bottom, bg.Width() * lane, height)
        End
    End
End

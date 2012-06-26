Strict

Private

Import mojo
Import bono
Import severity

Public

Class Chute Extends DisplayObject
    Private

    Field bottom:Image
    Field severity:Severity
    Field height:Int

    Public

    Field bg:Image

    Method New()
        bg = LoadImage("chute-bg.png")
        bottom = LoadImage("chute-bottom.png")
        severity = CurrentSeverity()
        Restart()
    End

    Method Restart:Void()
        height = 50
    End

    Method Height:Int()
        Return height
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

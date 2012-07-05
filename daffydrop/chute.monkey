Strict

Private

Import mojo
Import bono
Import severity

Public

Class Chute Extends BaseObject
    Private

    Field bottom:Image
    Field severity:Severity
    Field height:Int
    Field width:Int

    Public

    Field bg:Image

    Method OnCreate:Void(director:Director)
        bg = LoadImage("chute-bg.png")
        width = bg.Width()
        bottom = LoadImage("chute-bottom.png")
        severity = CurrentSeverity()
        Restart()
        Super.OnCreate(director)
    End

    Method Restart:Void()
        height = 50
    End

    Method Height:Int()
        Return height
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        If severity.ChuteShouldAdvance()
            height += severity.ChuteAdvanceHeight()
            severity.ChuteMarkAsAdvanced()
        End
    End

    Method OnRender:Void()
        For Local posY:Float = 0 To height Step 6
            DrawImage(bg, 46 + width * 0, posY)
            DrawImage(bg, 46 + width * 1, posY)
            DrawImage(bg, 46 + width * 2, posY)
            DrawImage(bg, 46 + width * 3, posY)
        End

        ' The end of the tube is a little bit wider and it's quite ugly if
        ' it's aligned on the left
        DrawImage(bottom, 46 - 2 + width * 0, height)
        DrawImage(bottom, 46 - 2 + width * 1, height)
        DrawImage(bottom, 46 - 2 + width * 2, height)
        DrawImage(bottom, 46 - 2 + width * 3, height)
    End
End

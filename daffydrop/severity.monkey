Strict

Private

Import mojo

Global globalSeverityInstance:Severity

Public

Function CurrentSeverity:Severity()
    If Not globalSeverityInstance Then globalSeverityInstance = New Severity()
    Return globalSeverityInstance
End

Function CurrentSeverityReset:Void()
    globalSeverityInstance = Null
End

Const EASY:Int = 0
Const NORMAL:Int = 1
Const ADVANCED:Int = 2

Class Severity
    Private

    Field level:Int
    Field nextChuteAdvanceTime:Int
    Field nextShapeDropTime:Int
    Field lastTime:Int

    Public

    Method Set:Void(level:Int)
        Self.level = level
    End

    Method ToString:String()
        If level = EASY
            Return "easy"
        ElseIf level = NORMAL
            Return "normal"
        Else
            Return "adv."
        End
    End

    Method Restart:Void()
        ChuteMarkAsAdvanced()
        ShapeDropped()
    End

    Method WarpTime:Void(diff:Int)
        nextChuteAdvanceTime += diff
        nextShapeDropTime += diff
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        lastTime = Millisecs()
    End

    Method ChuteShouldAdvance:Bool()
        Return lastTime >= nextChuteAdvanceTime
    End

    Method ChuteAdvanceHeight:Int()
        Return 25
    End

    Method ChuteMarkAsAdvanced:Void()
        nextChuteAdvanceTime = lastTime + 3000
    End

    Method ShapeShouldBeDropped:Bool()
        Return lastTime >= nextShapeDropTime
    End

    Method ShapeDropped:Void()
        nextShapeDropTime = lastTime + 1000
    End
End

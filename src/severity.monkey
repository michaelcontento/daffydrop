Strict

Import bono

Global globalSeverityInstance:Severity

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
    Field level:Int
    Field nextChuteAdvanceTime:Int
    Field nextShapeDropTime:Int
    Field lastTime:Int

    Method Set:Void(level:Int)
        Self.level = level
        ChuteMarkAsAdvanced()
        ShapeDropped()
    End

    Method OnUpdate:Void()
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
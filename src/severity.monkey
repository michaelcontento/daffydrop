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

    Method Set:Void(level:Int)
        Self.level = level
    End

    Method OnUpdate:Void()
    End

    Method ChuteShouldAdvance:Bool()
        Return False
    End

    Method ChuteAdvanceHeight:Int()
        Return 0
    End

    Method ChuteMarkAsAdvanced:Void()
    End

    Method ShapeShouldBeDropped:Bool()
        Return False
    End

    Method ShapeDropped:Void()
    End




    Method GetAutoAdvanceStartDelay:Int()
        Return 4000
    End

    Method GetAutoAdvanceTime:Int()
        Return 6000 - (level * 2000)
    End

    Method GetAutoAdvanceHeight:Int()
        Return 25 + (level * 10)
    End

    Method GetShapeDropDelay:Int()
        Return 600 - (level * 200)
    End
End

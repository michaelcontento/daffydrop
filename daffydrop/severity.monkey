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
    Field shapeTypes:Int[] = [0, 1, 2, 3]
    Field lastTypes:IntStack = New IntStack()

    Public

    Method Set:Void(level:Int)
        Self.level = level

        lastTypes.Clear()
        RandomizeShapeTypes()
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
        RandomizeShapeTypes()
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
        If level = EASY
            Return 20
        ElseIf level = NORMAL
            Return 25
        Else
            Return 30
        End
    End

    Method ChuteMarkAsAdvanced:Void()
        Select level
        Case EASY
            nextChuteAdvanceTime = lastTime + Rnd(6000, 7000)
        Case NORMAL
            nextChuteAdvanceTime = lastTime + Rnd(5000, 6000)
        Case ADVANCED
            nextChuteAdvanceTime = lastTime + Rnd(4000, 5000)
        End
    End

    Method ShapeShouldBeDropped:Bool()
        Return lastTime >= nextShapeDropTime
    End

    Method ShapeDropped:Void()
        nextShapeDropTime = lastTime + 1000
    End

    Method RandomType:Int()
        Local activatedShapes:Int
        Select level
        Case EASY
            activatedShapes = 2
        Case NORMAL
            activatedShapes = 3
        Case ADVANCED
            activatedShapes = 4
        End

        Local newType:Int
        Local finished:Bool

        Repeat
            finished = True
            newType = Int(Rnd(0, activatedShapes))

            If lastTypes.Length() >= 2
                If lastTypes.Get(0) = newType
                    If lastTypes.Get(1) = newType
                        finished = False
                    End
                End
            End
        Until finished = True

        If lastTypes.Length() >= 2 Then lastTypes.Remove(0)
        lastTypes.Push(newType)
        Return shapeTypes[newType]
    End

    Method RandomLane:Int()
        Return Int(Rnd(0, 4))
    End

    Private

    Method RandomizeShapeTypes:Void()
        Local swapIndex:Int
        Local tmpType:Int

        For Local i:Int = 0 Until shapeTypes.Length()
            Repeat
                swapIndex = Int(Rnd(0, shapeTypes.Length()))
            Until swapIndex <> i

            tmpType = shapeTypes[i]
            shapeTypes[i] = shapeTypes[swapIndex]
            shapeTypes[swapIndex] = tmpType
        End
    End
End

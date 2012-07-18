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
    Field laneTimes:Int[] = [0, 0, 0, 0]
    Field lastTypes:IntStack = New IntStack()
    Field activatedShapes:Int
    Field startTime:Int
    Field slowDownDuration:Int

    Public

    Field progress:Float = 1.0

    Method Set:Void(level:Int)
        Self.level = level
        Restart()
    End

    Method ToString:String()
        If level = EASY
            Return "easy"
        ElseIf level = NORMAL
            Return "norm"
        Else
            Return "adv."
        End
    End

    Method Restart:Void()
        Select level
        Case EASY
            activatedShapes = 2
            slowDownDuration = 160000
        Case NORMAL
            activatedShapes = 3
            slowDownDuration = 140000
        Case ADVANCED
            activatedShapes = 4
            slowDownDuration = 120000
        End

        lastTypes.Clear()
        ChuteMarkAsAdvanced()
        ShapeDropped()
        RandomizeShapeTypes()
        progress = 1.0
        startTime = Millisecs()
    End

    Method WarpTime:Void(diff:Int)
        nextChuteAdvanceTime += diff
        nextShapeDropTime += diff
        lastTime += diff
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        lastTime = Millisecs()
        If progress > 0
            progress = 1.0 - (1.0 / slowDownDuration * (lastTime - startTime))
            progress = Max(0.0, progress)
        End
    End

    Method ChuteShouldAdvance:Bool()
        Return lastTime >= nextChuteAdvanceTime
    End

    Method ChuteAdvanceHeight:Int()
        Return 40
    End

    Method ChuteMarkAsAdvanced:Void()
        nextChuteAdvanceTime = Rnd(2000, 4000)

        Select level
        Case EASY
            nextChuteAdvanceTime += 5000 * progress
        Case NORMAL
            nextChuteAdvanceTime += 5000 * progress
        Case ADVANCED
            nextChuteAdvanceTime += 5000 * progress
        End

        nextChuteAdvanceTime *= 2
        nextChuteAdvanceTime += lastTime
    End

    Method ShapeShouldBeDropped:Bool()
        Return lastTime >= nextShapeDropTime
    End

    Method ShapeDropped:Void()
        Select level
        Case EASY
            nextShapeDropTime = lastTime + Rnd(450, 1800 + (2500 * progress))
        Case NORMAL
            nextShapeDropTime = lastTime + Rnd(375, 1800 + (2500 * progress))
        Case ADVANCED
            nextShapeDropTime = lastTime + Rnd(300, 1800 + (2500 * progress))
        End
    End

    Method MinSliderTypes:Int()
        If level = EASY
            Return 2
        ElseIf level = NORMAL
            Return 3
        Else
            Return 4
        End
    End

    Method RandomType:Int()
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

    Method ConfigureSlider:Void(config:IntList)
        Local usedTypes:IntSet = New IntSet()
        config.Clear()

        For Local i:Int = 0 Until MinSliderTypes()
            usedTypes.Insert(shapeTypes[i])
            config.AddLast(shapeTypes[i])
        End

        While config.Count() < 4
            If usedTypes.Count() >= activatedShapes Or Rnd() < 0.5
                config.AddLast(shapeTypes[Int(Rnd(0, usedTypes.Count()))])
            Else
                config.AddLast(shapeTypes[usedTypes.Count()])
                usedTypes.Insert(shapeTypes[usedTypes.Count()])
            End
        End

        activatedShapes = usedTypes.Count()
    End

    Method RandomLane:Int()
        Local newLane:Int
        Local now:Int = Millisecs()

        Repeat
            newLane = Int(Rnd(0, 4))
        Until laneTimes[newLane] < now

        laneTimes[newLane] = now + 1400

        Return newLane
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

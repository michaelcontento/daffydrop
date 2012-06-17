Strict

Import mojo
Import bono
Import chute
Import slider
Import shape

Class ShapeMaster Implements Animationable
    Field upperObjectPool:Layer
    Field lowerObjectPool:Layer
    Field chute:Chute
    Field slider:Slider

    Field nextTick:Int
    Field dropTime:Int = 3000
    Field dropStartDelay:Int = 2000

    Method New(chute:Chute, slider:Slider)
        Self.chute = chute
        Self.slider = slider
    End

    Method Restart:Void()
        upperObjectPool = New Layer()
        lowerObjectPool = New Layer()
        nextTick = Millisecs() + dropStartDelay
    End

    Method CheckShapeCollisions:Void()
        For Local obj:Animationable = EachIn upperObjectPool.objects
            Local shape:Shape = Shape(obj)
            Local checkPosY:Int = CurrentGame().size.y - (slider.images[0].Height() / 2) - 15
            Local match:Bool = slider.Match(shape)

            If shape.pos.y + shape.images[0].Height() >= checkPosY
                upperObjectPool.Remove(shape)
                If match Then lowerObjectPool.Add(shape)
            End

            If match And KeyDown(KEY_DOWN) Then shape.isFast = True
        End
    End

    Method OnUpdate:Void()
        lowerObjectPool.OnUpdate()
        upperObjectPool.OnUpdate()
        slider.OnUpdate()
        chute.OnUpdate()
        CheckShapeCollisions()

        If Millisecs() <= nextTick Then Return
        nextTick = Millisecs() + dropTime

        upperObjectPool.Add(New Shape(RandomType(), RandomLane(), chute))
    End

    Method OnRender:Void()
        lowerObjectPool.OnRender()
        slider.OnRender()
        upperObjectPool.OnRender()
        chute.OnRender()
    End

    Method RandomType:Int()
        Return Int(Rnd() * 10) Mod 4
    End

    Method RandomLane:Int()
        Return Int(Rnd() * 10) Mod 4
    End
End

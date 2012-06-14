Strict

Import mojo

Import game
Import scene
Import sprite
Import animationable
Import layer
Import vector2d

Const TYPE_CIRCLE:Int = 0
Const TYPE_PLUS:Int = 1
Const TYPE_STAR:Int = 2
Const TYPE_TIRE:Int = 3

Class Shape Implements Animationable
    Global images:Image[]
    Field type:Int
    Field lane:Int
    Field chute:Chute
    Field pos:Vector2D

    Field speedSlow:Vector2D
    Field speedFast:Vector2D
    Field isFast:Bool = False

    Method New(type:Int, lane:Int, chute:Chute)
        Self.type = type
        Self.lane = lane
        Self.chute = chute

        LoadSharedImages()
        pos = New Vector2D(lane * chute.bg.Width(), chute.height - images[type].Height())
        speedSlow = New Vector2D(0, 4)
        speedFast = New Vector2D(0, 12)
    End

    Method LoadSharedImages:Void()
        If images.Length() > 0 Then Return
        images = [LoadImage("circle_inside.png"), LoadImage("plus_inside.png"), LoadImage("star_inside.png"), LoadImage("tire_inside.png")]
    End

    Method OnUpdate:Void()
        If isFast
            pos.Add(speedFast)
        Else
            pos.Add(speedSlow)
        End
    End

    Method OnRender:Void()
        DrawImage(images[type], pos.x, pos.y)
    End
End

Class Chute Implements Animationable
    Field bottom:Image
    Field bg:Image
    Field height:Int = 50

    Field nextTick:Int
    Field autoAdvanceTime:Int = 6000
    Field autoAdvanceStartDelay:Int = 6000
    Field autoAdvanceHeight:Int = 25

    Method New()
        bg = LoadImage("chute-bg.png")
        bottom = LoadImage("chute-bottom.png")
        nextTick = Millisecs() + autoAdvanceStartDelay
    End

    Method OnUpdate:Void()
        If Millisecs() > nextTick
            nextTick = Millisecs() + autoAdvanceTime
            height += autoAdvanceHeight
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

Class Slider Implements Animationable
    Field images:Image[]
    Field config:IntList
    Field arrowRight:Sprite
    Field arrowLeft:Sprite
    Field direction:Int
    Field movementStart:Int
    Field movementActive:Bool

    Const DURATION:Int = 500
    Const LEFT:Int = 1
    Const RIGHT:Int = 2

    Method New()
        images = [LoadImage("circle_outside.png"), LoadImage("plus_outside.png"), LoadImage("star_outside.png"), LoadImage("tire_outside.png")]
        config = New IntList()
        config.AddLast(TYPE_CIRCLE)
        config.AddLast(TYPE_PLUS)
        config.AddLast(TYPE_STAR)
        config.AddLast(TYPE_TIRE)

        arrowRight = New Sprite("arrow_ingame.png")
        arrowRight.pos.y = CurrentGame().size.y - arrowRight.size.y

        arrowLeft = New Sprite("arrow_ingame2.png")
        arrowLeft.pos = CurrentGame().size.Copy().Sub(arrowLeft.size)
    End

    Method Match:Bool(shape:Shape)
        If movementActive Then Return False

        Local configArray:Int[] = config.ToArray()
        If shape.type = configArray[shape.lane] Then Return True

        Return False
    End

    Method OnUpdate:Void()
        If movementActive Then Return

        If KeyDown(KEY_LEFT)
            direction = LEFT
            movementStart = Millisecs()
            movementActive = True
        End

        If KeyDown(KEY_RIGHT)
            direction = RIGHT
            movementStart = Millisecs()
            movementActive = True
        End
    End

    Method GetMovementOffset:Float()
        If Not movementActive Then Return 0

        Local now:Int = Millisecs()
        Local percent:Float = 100
        Local movementOffset:Float = 0

        If movementStart + DURATION >= now
            percent = Ceil(100.0 / DURATION * (now - movementStart))
            movementOffset = Ceil(images[0].Width() / 100.0 * percent)
        End

        If direction = LEFT
            movementOffset *= -1
        End

        If movementStart + DURATION < now
            movementActive = False
            If direction = LEFT
                Local tmpType:Int = config.First()
                config.RemoveFirst()
                config.AddLast(tmpType)
            Else
                Local tmpType:Int = config.Last()
                config.RemoveLast()
                config.AddFirst(tmpType)
            End
        End

        Return movementOffset
    End

    Method OnRender:Void()
        Local posX:Int = 45 + GetMovementOffset()
        Local posY:Int = CurrentGame().size.y - images[0].Height() - 60

        If posX > 45
            Local img:Image = images[config.Last()]
            DrawImage(img, (img.Width() * -1) + posX, posY)
        End

        If posX < 45
            Local img:Image = images[config.First()]
            DrawImage(img, (img.Width() * 4) + posX, posY)
        End

        For Local type:Int = EachIn config
            DrawImage(images[type], posX, posY)
            posX += images[type].Width()
        End

        arrowLeft.OnRender()
        arrowRight.OnRender()
    End
End

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

Class GameScene Extends Scene
    Field shapeMaster:ShapeMaster

    Method OnCreate:String()
        Local chute:Chute = New Chute()
        Local slider:Slider = New Slider()
        shapeMaster = New ShapeMaster(chute, slider)

        layer.Add(New Sprite("bg_960x640.png"))
        layer.Add(shapeMaster)

        Return "game"
    End

    Method OnEnter:Void()
        shapeMaster.Restart()
    End
End

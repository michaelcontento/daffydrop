Strict

Import mojo

Import game
Import scene
Import sprite
Import gameobject
Import gameobjectpool

Const TYPE_CIRCLE:Int = 0
Const TYPE_PLUS:Int = 1
Const TYPE_STAR:Int = 2
Const TYPE_TIRE:Int = 3

Class Shape Extends GameObject
    Global images:Image[]
    Field type:Int
    Field lane:Int
    Field chute:Chute
    Field posY:Int

    Field speedSlow:Int = 4
    Field speedFast:Int = 12
    Field isFast:Bool = False

    Method New(type:Int, lane:Int, chute:Chute)
        Self.type = type
        Self.lane = lane
        Self.chute = chute
        LoadSharedImages()
        posY = chute.height - images[type].Height()
    End

    Method LoadSharedImages:Void()
        If images.Length() > 0 Then Return
        images = [LoadImage("circle_inside.png"), LoadImage("plus_inside.png"), LoadImage("star_inside.png"), LoadImage("tire_inside.png")]
    End

    Method OnUpdate:Void()
        If isFast
            posY += speedFast
        Else
            posY += speedSlow
        End
    End

    Method OnRender:Void()
        DrawImage(images[type], lane * chute.bg.Width(), posY)
    End
End

Class Chute Extends GameObject
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

Class Slider Extends GameObject
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
        arrowRight.y = CurrentGame().Height() - arrowRight.image.Height()

        arrowLeft = New Sprite("arrow_ingame2.png")
        arrowLeft.x = CurrentGame().Width() - arrowLeft.image.Width()
        arrowLeft.y = CurrentGame().Height() - arrowLeft.image.Height()
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
        Local posY:Int = CurrentGame().Height() - images[0].Height() - 60

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

Class ShapeMaster Extends GameObject
    Field upperObjectPool:GameObjectPool
    Field lowerObjectPool:GameObjectPool
    Field chute:Chute
    Field slider:Slider

    Field nextTick:Int
    Field dropTime:Int = 3000
    Field dropStartDelay:Int = 2000

    Method New(chute:Chute, slider:Slider)
        Self.chute = chute
        Self.slider = slider
        upperObjectPool = New GameObjectPool()
        lowerObjectPool = New GameObjectPool()
        nextTick = Millisecs() + dropStartDelay
    End

    Method CheckShapeCollisions:Void()
        For Local obj:GameObject = EachIn upperObjectPool.list
            Local shape:Shape = Shape(obj)
            Local checkPosY:Int = CurrentGame().Height() - (slider.images[0].Height() / 2) - 15
            Local match:Bool = slider.Match(shape)

            If shape.posY + shape.images[0].Height() >= checkPosY
                upperObjectPool.Remove(shape)
                If match Then lowerObjectPool.Add(shape)
            End

            If match And KeyDown(KEY_DOWN) Then shape.isFast = True
        End
    End

    Method OnUpdate:Void()
        CheckShapeCollisions()

        If Millisecs() <= nextTick Then Return
        nextTick = Millisecs() + dropTime

        upperObjectPool.Add(New Shape(RandomType(), RandomLane(), chute))
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
    Field slider:Slider
    Field chute:Chute

    Method OnCreate:String()
        chute = New Chute()
        slider = New Slider()
        shapeMaster = New ShapeMaster(chute, slider)

        pool.Add(New Sprite("bg_960x640.png"))
        pool.Add(shapeMaster)
        pool.Add(shapeMaster.lowerObjectPool)
        pool.Add(slider)
        pool.Add(shapeMaster.upperObjectPool)
        pool.Add(chute)

        Return "game"
    End
End

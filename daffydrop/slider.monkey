Strict

Private

Import mojo
Import bono
Import shape

Public

Const TYPE_CIRCLE:Int = 0
Const TYPE_PLUS:Int = 1
Const TYPE_STAR:Int = 2
Const TYPE_TIRE:Int = 3

Class Slider Extends BaseObject
    Private

    Field config:IntList
    Field configArray:Int[]
    Field direction:Int
    Field movementStart:Int
    Field movementActive:Bool
    Field posY:Float

    Public

    Field arrowLeft:Sprite
    Field arrowRight:Sprite
    Field images:Image[]
    Const DURATION:Int = 300
    Const LEFT:Int = 1
    Const RIGHT:Int = 2

    Method OnCreate:Void(director:Director)
        images = [LoadImage("circle_outside.png"), LoadImage("plus_outside.png"), LoadImage("star_outside.png"), LoadImage("tire_outside.png")]
        config = New IntList()
        config.AddLast(TYPE_CIRCLE)
        config.AddLast(TYPE_PLUS)
        config.AddLast(TYPE_STAR)
        config.AddLast(TYPE_TIRE)
        configArray = config.ToArray()

        arrowLeft = New Sprite("arrow_ingame.png")
        arrowLeft.pos.y = director.size.y - arrowLeft.size.y

        arrowRight = New Sprite("arrow_ingame2.png")
        arrowRight.pos = director.size.Copy().Sub(arrowRight.size)

        Super.OnCreate(director)

        posY = director.size.y - images[0].Height() - 60
    End

    Method SlideLeft:Void()
        If movementActive Then Return
        direction = LEFT
        movementStart = Millisecs()
        movementActive = True
    End

    Method SlideRight:Void()
        If movementActive Then Return
        direction = RIGHT
        movementStart = Millisecs()
        movementActive = True
    End

    Method pos:Vector2D() Property
        Return arrowLeft.pos
    End

    Method OnRender:Void()
        Local posX:Float = 46 + GetMovementOffset()
        Local img:Image

        PushMatrix()
            SetColor(255, 255, 255)
            DrawRect(0, posY + images[config.First()].Height(), director.size.x, director.size.y)
        PopMatrix()

        If posX > 46
            img = images[config.Last()]
            DrawImage(img, (img.Width() * -1) + posX, posY)
        End

        If posX < 46
            img = images[config.First()]
            DrawImage(img, (img.Width() * 4) + posX, posY)
        End

        For Local type:Int = EachIn config
            DrawImage(images[type], posX, posY)
            posX += images[type].Width()
        End

        arrowRight.OnRender()
        arrowLeft.OnRender()
    End

    Private

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
                configArray = config.ToArray()
            Else
                Local tmpType:Int = config.Last()
                config.RemoveLast()
                config.AddFirst(tmpType)
                configArray = config.ToArray()
            End
        End

        Return movementOffset
    End

    Method Match:Bool(shape:Shape)
        If movementActive Then Return False
        If shape.type = configArray[shape.lane] Then Return True
        Return False
    End
End

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

Class Slider Extends GameObject
    Field images:Image[]
    Field config:Int[]
    Field arrowRight:Sprite
    Field arrowLeft:Sprite

    Method New()
        images = [LoadImage("circle_outside.png"), LoadImage("plus_outside.png"), LoadImage("star_outside.png"), LoadImage("tire_outside.png")]
        config = [TYPE_CIRCLE, TYPE_PLUS, TYPE_STAR, TYPE_TIRE]

        arrowRight = New Sprite("arrow_ingame.png")
        arrowRight.x = 0
        arrowRight.y = Game.GetInstance().Height() - arrowRight.image.Height()

        arrowLeft = New Sprite("arrow_ingame2.png")
        arrowLeft.x = Game.GetInstance().Width() - arrowLeft.image.Width()
        arrowLeft.y = Game.GetInstance().Height() - arrowLeft.image.Height()
    End

    Method OnRender:Void()
        Local posX:Int = 45
        Local posY:Int = Game.GetInstance().Height() - images[TYPE_CIRCLE].Height() - 60

        For Local type:Int = EachIn config
            DrawImage(images[type], posX, posY)
            posX += images[type].Width()
        End

        arrowLeft.OnRender()
        arrowRight.OnRender()
    End
End

Class GameScene Extends Scene
    Field gameObjectPool:GameObjectPool

    Method New()
        name = "game"
        gameObjectPool = New GameObjectPool()
    End

    Method OnEnter:Void()
        gameObjectPool.Add(New Sprite("bg_960x640.png"))
        gameObjectPool.Add(New Slider())
    End

    Method OnUpdate:Void()
        gameObjectPool.OnUpdate()
    End

    Method OnRender:Void()
        gameObjectPool.OnRender()
    End
End

Strict

Import mojo

Import game
Import animationable
Import vector2d

Class Sprite Implements Animationable
    Field image:Image
    Field pos:Vector2D
    Field rotation:Float
    Field scale:Vector2D
    Field frame:Int

    Field WIDTH:Int
    Field WIDTH2:Int
    Field HEIGHT:Int
    Field HEIGHT2:Int

    Method New(imageName:String)
        Init(imageName, New Vector2D(0, 0))
    End

    Method New(imageName:String, pos:Vector2D)
        Init(imageName, pos)
    End

    Method Init:Void(imageName:String, pos:Vector2D)
        Self.pos = pos
        scale = New Vector2D(1, 1)

        image = LoadImage(imageName)
        CalculateDimensions()
    End

    Method CalculateDimensions:Void()
        HEIGHT = image.Height()
        HEIGHT2 = HEIGHT / 2

        WIDTH = image.Width()
        WIDTH2 = WIDTH / 2
    End

    Method OnRender:Void()
        DrawImage(image, pos.x, pos.y, rotation, scale.x, scale.y, frame)
    End

    Method OnUpdate:Void()
    End

    Method CenterGameX:Void()
        pos.x = CurrentGame().WIDTH2 - WIDTH2
    End

    Method CenterGameY:Void()
        pos.y = CurrentGame().HEIGHT2 - HEIGHT2
    End

    Method CenterGame:Void()
        CenterGameX()
        CenterGameY()
    End
End

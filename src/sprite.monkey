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
    Field size:Vector2D
    Field center:Vector2D
    Field frame:Int

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
        size = New Vector2D(image.Width(), image.Height())
        center = size.Copy().Div(2)
    End

    Method OnRender:Void()
        DrawImage(image, pos.x, pos.y, rotation, scale.x, scale.y, frame)
    End

    Method OnUpdate:Void()
    End

    Method CenterGameX:Void()
        pos.x = CurrentGame().center.x - center.x
    End

    Method CenterGameY:Void()
        pos.y = CurrentGame().center.y - center.y
    End

    Method CenterGame:Void()
        pos = CurrentGame().center.Copy().Sub(center)
    End
End

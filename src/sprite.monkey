Strict

Import mojo

Import game
Import animationable

Class Sprite Implements Animationable
    Field image:Image

    Field x:Float
    Field y:Float
    Field rotation:Float
    Field scaleX:Float = 1
    Field scaleY:Float = 1
    Field frame:Int

    Field WIDTH:Int
    Field WIDTH2:Int
    Field HEIGHT:Int
    Field HEIGHT2:Int

    Method New(imageName:String, x:Float=0, y:Float=0)
        image = LoadImage(imageName)
        CalculateDimensions()
        Self.x = x
        Self.y = y
    End

    Method CalculateDimensions:Void()
        HEIGHT = image.Height()
        HEIGHT2 = HEIGHT / 2

        WIDTH = image.Width()
        WIDTH2 = WIDTH / 2
    End

    Method OnRender:Void()
        DrawImage(image, x, y, rotation, scaleX, scaleY, frame)
    End

    Method OnUpdate:Void()
    End

    Method CenterGameX:Void()
        x = CurrentGame().WIDTH2 - WIDTH2
    End

    Method CenterGameY:Void()
        y = CurrentGame().HEIGHT2 - HEIGHT2
    End

    Method CenterGame:Void()
        CenterGameX()
        CenterGameY()
    End
End

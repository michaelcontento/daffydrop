Strict

Import mojo

Import game
Import gameobject

Class Sprite Extends GameObject
    Field image:Image

    Field x:Float
    Field y:Float

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
        DrawImage(image, x, y)
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

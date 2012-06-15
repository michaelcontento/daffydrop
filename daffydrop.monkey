Strict

Import src.bono.game
Import src.introscene
Import src.menuscene
Import src.gamescene

#GLFW_WINDOW_WIDTH=320
#GLFW_WINDOW_HEIGHT=480
#IOS_ACCELEROMETER_ENABLED="false"

Function Main:Int()
    Local game:Game = CurrentGame()
    game.scenes.Add(New IntroScene())
    game.scenes.Add(New MenuScene())
    game.scenes.Add(New GameScene())
    game.Run()
    Return 0
End

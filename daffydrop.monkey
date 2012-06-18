Strict

Import src.bono.game
Import src.introscene
Import src.menuscene
Import src.gamescene
Import src.highscorescene

#GLFW_WINDOW_WIDTH=480
#GLFW_WINDOW_HEIGHT=720
#IOS_ACCELEROMETER_ENABLED="false"

Function Main:Int()
    Local game:Game = CurrentGame()
    game.scenes.Add(New IntroScene())
    game.scenes.Add(New MenuScene())
    game.scenes.Add(New GameScene())
    game.scenes.Add(New HighscoreScene())
    game.Run()
    Return 0
End

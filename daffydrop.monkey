Strict

Import src.game
Import src.introscene
Import src.menuscene

#GLFW_WINDOW_WIDTH=640
#GLFW_WINDOW_HEIGHT=960
#IOS_ACCELEROMETER_ENABLED="false"

Function Main:Int()
    Local game:Game = Game.GetInstance()
    game.sceneManager.Add(New IntroScene())
    game.sceneManager.Add(New MenuScene())
    game.Run()
    Return 0
End

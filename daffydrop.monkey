Strict

Private

Import daffydrop.bono
Import daffydrop.introscene
Import daffydrop.menuscene
Import daffydrop.gamescene
Import daffydrop.highscorescene

Public

#GLFW_WINDOW_WIDTH=480
#GLFW_WINDOW_HEIGHT=720
#IOS_ACCELEROMETER_ENABLED="false"

Function Main:Int()
    Local director:Director = CurrentDirector()
    director.inputController.touchFingers = 1
    director.inputController.touchRetainSize = 25
    director.scenes.Add(New IntroScene())
    director.scenes.Add(New MenuScene())
    director.scenes.Add(New GameScene())
    director.scenes.Add(New HighscoreScene())
    director.Run()
    Return 0
End

Strict

Private

Import daffydrop.bono
Import daffydrop.gameoverscene
Import daffydrop.newhighscorescene
Import daffydrop.gamescene
Import daffydrop.highscorescene
Import daffydrop.introscene
Import daffydrop.menuscene

Public

#GLFW_WINDOW_WIDTH=480
#GLFW_WINDOW_HEIGHT=720
#IOS_ACCELEROMETER_ENABLED="false"
#DISPLAY_LINK_ENABLED="true"

Function Main:Int()
    Local director:Director = New Director(640, 960)
    director.inputController.touchFingers = 1
    director.inputController.touchRetainSize = 25
    director.scenes.Add(New GameOverScene())
    director.scenes.Add(New GameScene())
    director.scenes.Add(New HighscoreScene())
    director.scenes.Add(New IntroScene())
    director.scenes.Add(New MenuScene())
    director.scenes.Add(New NewHighscoreScene())
#If CONFIG="debug"
    director.Run("menu")
#Else
    director.Run("intro")
#End
    Return 0
End

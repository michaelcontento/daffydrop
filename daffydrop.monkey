Strict

Private

Import daffydrop.bono
Import daffydrop.gameoverscene
Import daffydrop.newhighscorescene
Import daffydrop.pausescene
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
    Local router:Router = New Router()
    router.Add("intro", New IntroScene())
    router.Add("menu", New MenuScene())
    router.Add("highscore", New HighscoreScene())
    router.Add("game", New GameScene())
    router.Add("gameover", New GameOverScene())
    router.Add("pause", New PauseScene())
    router.Add("newhighscore", New NewHighscoreScene())
#If CONFIG="debug"
    router.Goto("menu")
#Else
    router.Goto("intro")
#End

    Local director:Director = New Director(640, 960)
#If TARGET="glfw"
    director.inputController.trackKeys = True
#End
    director.inputController.trackTouch = True
    director.inputController.touchFingers = 1
    director.inputController.touchRetainSize = 25
    director.Run(router)
    Return 0
End

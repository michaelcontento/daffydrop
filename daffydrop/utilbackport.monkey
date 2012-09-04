Private

Import "native/utilbackport.${TARGET}.${LANG}"

Public

Extern

Class UtilBackport Abstract
#If TARGET="ios" Or TARGET="glfw"
    Function GetTimestamp:Int()="utilBackport::GetTimestamp"
    Function OpenUrl:Void(url:String)="utilBackport::OpenUrl"
#Else
    Function GetTimestamp:Int()="utilBackport.GetTimestamp"
    Function OpenUrl:Void(url:String)="utilBackport.OpenUrl"
#End
End

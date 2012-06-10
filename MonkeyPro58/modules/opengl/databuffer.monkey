
#If LANG="cpp" Or LANG="java" Or LANG="js"

#If LANG="cpp"
Import "native/databuffer.cpp"
#ElseIf LANG="java"
Import "native/databuffer.java"
#ElseIf LANG="js"
Import "native/databuffer.js"
#Endif

Extern

Class DataBuffer

	Method Size()

	Method Discard:Void()
	
	Method PokeByte:Void( addr,value )
	Method PokeShort:Void( addr,value )
	Method PokeInt:Void( addr,value )
	Method PokeFloat:Void( addr,value# )
	
	Method PeekByte:Int( addr )
	Method PeekShort:Int( addr )
	Method PeekInt:Int( addr )
	Method PeekFloat:Float( addr )

#if LANG="cpp"
	Function Create:DataBuffer( size )="DataBuffer::Create"
#ElseIf LANG="java"
	Function Create:DataBuffer( size )="DataBuffer.Create"
#ElseIf LANG="js"
	Function Create:DataBuffer( size )="createDataBuffer"
#Endif

End

#Endif


#include "main.h"

//${CONFIG_BEGIN}
//${CONFIG_END}

//${TRANSCODE_BEGIN}
//${TRANSCODE_END}

int main( int argc,const char **argv ){

	try{
	
		bb_std_main( argc,argv );
		
	}catch( const char *err ){
	
		Print( String("Monkey runtime error: ")+err+"\n"+StackTrace() );
	}
}

class DataBuffer{
	
	ByteBuffer _data;
	int _length;
	
	DataBuffer( int length ){
		_data=ByteBuffer.allocateDirect( length );
		_data.order( ByteOrder.nativeOrder() );
		_length=length;
	}

	int Size(){
		return _length;
	}
	
	void Discard(){
		if( _data!=null ){
			_data=null;
			_length=0;
		}
	}
		
	Buffer GetBuffer(){
		return _data;
	}
	
	void PokeByte( int addr,int value ){
		_data.put( addr,(byte)value );
	}
	
	void PokeShort( int addr,int value ){
		_data.putShort( addr,(short)value );
	}
	
	void PokeInt( int addr,int value ){
		_data.putInt( addr,value );
	}
	
	void PokeFloat( int addr,float value ){
		_data.putFloat( addr,value );
	}
	
	int PeekByte( int addr ){
		return _data.get( addr );
	}
	
	int PeekShort( int addr ){
		return _data.getShort( addr );
	}
	
	int PeekInt( int addr ){
		return _data.getInt( addr );
	}
	
	float PeekFloat( int addr ){
		return _data.getFloat( addr );
	}
	
	static DataBuffer Create( int length ){
		return new DataBuffer( length );
	}
}

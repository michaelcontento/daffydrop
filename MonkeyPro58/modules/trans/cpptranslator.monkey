
' Module trans.cpptranslator
'
' Placed into the public domain 24/02/2011.
' No warranty implied; use at your own risk.

Import trans

Const PROFILE?=True

Class CppTranslator Extends CTranslator

	Method TransType$( ty:Type )
		If VoidType( ty ) Return "void"
		If BoolType( ty ) Return "bool"
		If IntType( ty ) Return "int"
		If FloatType( ty ) Return "Float"
		If StringType( ty ) Return "String"
		If ArrayType( ty ) Return "Array<"+TransRefType( ArrayType(ty).elemType )+" >"
		If ObjectType( ty ) Return ty.GetClass().munged+"*"
		InternalErr
	End
	
	Method TransRefType$( ty:Type )
		Return TransType( ty )
	End
	
	Method TransValue$( ty:Type,value$ )
		If value
			If BoolType( ty ) Return "true"
			If IntType( ty ) Return value
			If FloatType( ty ) Return "FLOAT("+value+")"
			If StringType( ty ) Return "String("+Enquote( value )+")"
		Else
			If BoolType( ty ) Return "false"
			If NumericType( ty ) Return "0"
			If StringType( ty ) Return "String()"
			If ArrayType( ty ) Return "Array<"+TransRefType( ArrayType(ty).elemType )+" >()"
			If ObjectType( ty ) Return "0"
		Endif
		InternalErr
	End
	
	Method TransArgs$( args:Expr[],decl:FuncDecl )
		Local t$
		For Local arg:=Eachin args
			If t t+=","
			t+=arg.Trans()
		Next
		Return Bra(t)
	End
	
	'***** Utility *****
	
	Method TransLocalDecl$( munged$,init:Expr )
		Return TransType( init.exprType )+" "+munged+"="+init.Trans()
	End
	
	Method EmitEnter( func$ )
		If CONFIG_DEBUG Emit "pushErr();" Else Emit "profEnter(~q"+func+"~q);"
	End
	
	Method EmitSetErr( info$ )
		If CONFIG_DEBUG Emit "errInfo=~q"+info.Replace( "\","/" )+"~q;"
	End
	
	Method EmitLeave()
		If CONFIG_DEBUG Emit "popErr();" Else Emit "profLeave();"
	End

	'***** Declarations *****
	
	Method TransStatic$( decl:Decl )
		If decl.IsExtern()
			Return decl.munged
		Else If _env And decl.scope And decl.scope=_env.ClassScope()
			Return decl.munged
		Else If ClassDecl( decl.scope )
			Return decl.scope.munged+"::"+decl.munged
		Else If ModuleDecl( decl.scope )
			Return decl.munged
		Endif
		InternalErr
	End
	
	Method TransGlobal$( decl:GlobalDecl )
		Return TransStatic( decl )
	End
	
	Method TransField$( decl:FieldDecl,lhs:Expr )
		If lhs Return TransSubExpr( lhs )+"->"+decl.munged
		Return decl.munged
	End
		
	Method TransFunc$( decl:FuncDecl,args:Expr[],lhs:Expr )
		If decl.IsMethod()
			If lhs Return TransSubExpr( lhs )+"->"+decl.munged+TransArgs( args,decl )
			Return decl.munged+TransArgs( args,decl )
		Endif
		Return TransStatic( decl )+TransArgs( args,decl )
	End
	
	Method TransSuperFunc$( decl:FuncDecl,args:Expr[] )
		Return decl.ClassScope().munged+"::"+decl.munged+TransArgs( args,decl )
	End
	
	'***** Expressions *****

	Method TransConstExpr$( expr:ConstExpr )
		Return TransValue( expr.exprType,expr.value )
	End
	
	Method TransNewObjectExpr$( expr:NewObjectExpr )
		Local t$="(new "+expr.classDecl.munged+")"
		If expr.ctor t+="->"+expr.ctor.munged+TransArgs( expr.args,expr.ctor )
		Return t
	End
	
	Method TransNewArrayExpr$( expr:NewArrayExpr )
		Local texpr$=expr.expr.Trans()
		'
		Return "Array<"+TransRefType( expr.ty )+" >"+Bra( expr.expr.Trans() )
	End
		
	Method TransSelfExpr$( expr:SelfExpr )
		Return "this"
	End
	
	Method TransCastExpr$( expr:CastExpr )
	
		Local t$=Bra( expr.expr.Trans() )
		
		Local dst:=expr.exprType
		Local src:=expr.expr.exprType
		
		If BoolType( dst )
			If BoolType( src ) Return t
			If IntType( src ) Return Bra( t+"!=0" )
			If FloatType( src ) Return Bra( t+"!=0" )
			If ArrayType( src ) Return Bra( t+".Length()!=0" )
			If StringType( src ) Return Bra( t+".Length()!=0" )
			If ObjectType( src ) Return Bra( t+"!=0" )
		Else If IntType( dst )
			If BoolType( src ) Return Bra( t+"?1:0" )
			If IntType( src ) Return t
			If FloatType( src ) Return "int"+Bra(t)
			If StringType( src ) Return t+".ToInt()"
		Else If FloatType( dst )
			If IntType( src ) Return "Float"+Bra(t)
			If FloatType( src ) Return t
			If StringType( src ) Return t+".ToFloat()"
		Else If StringType( dst )
			If IntType( src ) Return "String"+Bra( t )
			If FloatType( src ) Return "String"+Bra( t )
			If StringType( src ) Return t
		Else If ObjectType( dst ) And ObjectType( src )
			If src.GetClass().IsInterface() And Not dst.GetClass().IsInterface()
				'interface->object
				Return "dynamic_cast<"+TransType(dst)+">"+Bra( t )
			Else  If src.GetClass().ExtendsClass( dst.GetClass() )
				'upcast
				Return t
			Else
				'downcast
				Return "dynamic_cast<"+TransType(dst)+">"+Bra( t )
			Endif
		Endif
		Err "C++ translator can't convert "+src.ToString()+" to "+dst.ToString()
	End
	
	Method TransUnaryExpr$( expr:UnaryExpr )
		Local pri=ExprPri( expr )
		Local t_expr$=TransSubExpr( expr.expr,pri )
		Return TransUnaryOp( expr.op )+t_expr
	End
	
	Method TransBinaryExpr$( expr:BinaryExpr )
		Local pri=ExprPri( expr )
		Local t_lhs$=TransSubExpr( expr.lhs,pri )
		Local t_rhs$=TransSubExpr( expr.rhs,pri-1 )
		If expr.op="mod" And FloatType( expr.exprType )
			Return "fmod("+t_lhs+","+t_rhs+")"
		Endif
		Return t_lhs+TransBinaryOp( expr.op,t_rhs )+t_rhs
	End
	
	Method TransIndexExpr$( expr:IndexExpr )
	
		Local t_expr:=TransSubExpr( expr.expr )
		Local t_index:=expr.index.Trans()
		
		If StringType( expr.expr.exprType ) Return "(int)"+t_expr+"["+t_index+"]"
		
		If ENV_CONFIG="debug" Return t_expr+".At("+t_index+")"
		
		Return t_expr+"["+t_index+"]"
	End
	
	Method TransSliceExpr$( expr:SliceExpr )
		Local t_expr:=TransSubExpr( expr.expr )
		Local t_args:="0"
		If expr.from t_args=expr.from.Trans()
		If expr.term t_args+=","+expr.term.Trans()
		Return t_expr+".Slice("+t_args+")"
	End
	
	Method TransArrayExpr$( expr:ArrayExpr )

		Local elemType:=ArrayType( expr.exprType ).elemType

		Local t$
		For Local elem:=Eachin expr.exprs
			Local e:=elem.Trans()
			If t t+=","
			t+=e
		Next
		
		Local tmp:=New LocalDecl( "",0,Type.voidType,Null )
		MungDecl tmp

		Emit TransRefType( elemType )+" "+tmp.munged+"[]={"+t+"};"
		
		Return "Array<"+TransRefType( elemType )+" >("+tmp.munged+","+expr.exprs.Length+")"
	End

	Method TransIntrinsicExpr$( decl:Decl,expr:Expr,args:Expr[] )
		Local texpr$,arg0$,arg1$,arg2$
		
		If expr texpr=TransSubExpr( expr )
		
		If args.Length>0 And args[0] arg0=args[0].Trans()
		If args.Length>1 And args[1] arg1=args[1].Trans()
		If args.Length>2 And args[2] arg2=args[2].Trans()
		
		Local id$=decl.munged[1..]
		Local id2$=id[..1].ToUpper()+id[1..]
		
		Select id

		'global functions
		Case "print" Return "Print"+Bra( arg0 )
		Case "error" Return "Error"+Bra( arg0 )

		'string/array methods
		Case "length" Return texpr+".Length()"
		Case "resize" Return texpr+".Resize"+Bra( arg0 )

		'string methods
		Case "compare" Return texpr+".Compare"+Bra( arg0 )
		Case "find" Return texpr+".Find"+Bra( arg0+","+arg1 )
		Case "findlast" Return texpr+".FindLast"+Bra( arg0 )
		Case "findlast2" Return texpr+".FindLast"+Bra( arg0+","+arg1 )
		Case "trim" Return texpr+".Trim()"
		Case "join" Return texpr+".Join"+Bra( arg0 )
		Case "split" Return texpr+".Split"+Bra( arg0 )
		Case "replace" Return texpr+".Replace"+Bra( arg0+","+arg1 )
		Case "tolower" Return texpr+".ToLower()"
		Case "toupper" Return texpr+".ToUpper()"
		Case "contains" Return texpr+".Contains"+Bra( arg0 )
		Case "startswith" Return texpr+".StartsWith"+Bra( arg0 )
		Case "endswith" Return texpr+".EndsWith"+Bra( arg0 )
		
		'string functions
		Case "fromchar" Return "String"+Bra( "(Char)"+Bra(arg0)+",1" )
		Case "fromchars" Return "String::FromChars"+Bra( arg0 )

		'trig functions - degrees
		Case "sin","cos","tan" Return "(Float)"+id+Bra( Bra(arg0)+"*D2R" )
		Case "asin","acos","atan" Return "(Float)"+Bra( id+Bra(arg0)+"*R2D" )
		Case "atan2" Return "(Float)"+Bra( id+Bra(arg0+","+arg1)+"*R2D" )

		'trig functions - radians
		Case "sinr","cosr","tanr" Return "(Float)"+id[..-1]+Bra( arg0 )
		Case "asinr","acosr","atanr" Return "(Float)"+id[..-1]+Bra( arg0 )
		Case "atan2r" Return "(Float)"+id[..-1]+Bra( arg0+","+arg1 )
		
		'misc math functions
		Case "sqrt","floor","ceil","log","exp" Return "(Float)"+id+Bra( arg0 )
		Case "pow" Return "(Float)"+id+Bra( arg0+","+arg1 )

		End Select
		
		InternalErr
	End

	'***** Statements *****

	Method TransAssignStmt2$( stmt:AssignStmt )
		'
		Local ty:=stmt.lhs.exprType
		
		If ObjectType( ty ) Or ArrayType( ty )
		
			'Ignore Object null assignments, ie: =Null
			If ObjectType( ty ) And ConstExpr( stmt.rhs )
				Return Super.TransAssignStmt2( stmt )
			Endif

			'Ignore 'unmanaged' objects...
			If ObjectType( ty ) And Not ty.GetClass().ExtendsObject()
				Return Super.TransAssignStmt2( stmt )
			Endif
			
			'Ignore local var assignments
			Local varExpr:=VarExpr( stmt.lhs )
			If varExpr And LocalDecl( varExpr.decl )
				Return Super.TransAssignStmt2( stmt )
			Endif
			
			Local t_lhs:=stmt.lhs.TransVar()
			Local t_rhs:=stmt.rhs.Trans()

			Return "gc_assign("+t_lhs+","+t_rhs+")"
			
		Endif
		Return Super.TransAssignStmt2( stmt )
	End
	
	'***** Declarations *****
	
	Method EmitFuncProto( decl:FuncDecl )
		Local args$
		For Local arg:=Eachin decl.argDecls
			If args args+=","
			args+=TransType( arg.type )
		Next
		
		Local t$=TransType( decl.retType )+" "+decl.munged+Bra( args )
		If decl.IsAbstract() t+="=0"
		
		Local q$
		If decl.IsMethod() q+="virtual "
		If decl.IsStatic() And decl.ClassScope() q+="static "
		
		Emit q+t+";"
	End
	
	Method EmitFuncDecl( decl:FuncDecl )
		If decl.IsAbstract() Return
		
		BeginLocalScope

		Local args$
		For Local arg:=Eachin decl.argDecls
			MungDecl arg
			If args args+=","
			args+=TransType( arg.type )+" "+arg.munged
		Next
		
		Local id$=decl.munged
		If decl.ClassScope() id=decl.ClassScope().munged+"::"+id
		
		Emit TransType( decl.retType )+" "+id+Bra( args )+"{"

		EmitBlock decl

		Emit "}"
		
		EndLocalScope
	End
	
	Method EmitClassProto( classDecl:ClassDecl )
	
		Local classid$=classDecl.munged
		Local superid$=classDecl.superClass.munged
		
		If classDecl.IsInterface()
			Local bases$
			For Local iface:=Eachin classDecl.implments
				If bases bases+="," Else bases=" : "
				bases+="public virtual "+iface.munged
			Next
			If Not bases bases=" : public virtual gc_interface"
			Emit "class "+classid+bases+"{"
			Emit "public:"
			Local emitted:=New Stack<FuncDecl>
			For Local decl:=Eachin classDecl.Semanted
				Local fdecl:=FuncDecl(decl)
				If Not fdecl Continue
				EmitFuncProto fdecl
				emitted.Push fdecl
			Next
			For Local iface:=Eachin classDecl.implmentsAll
				For Local decl:=Eachin iface.Semanted
					Local fdecl:=FuncDecl(decl)
					If Not fdecl Continue
					Local found
					For Local fdecl2:=Eachin emitted
						If fdecl.ident<>fdecl2.ident Continue
						If Not fdecl.EqualsFunc( fdecl2 ) Continue
						found=True
						Exit
					Next
					If found Continue
					EmitFuncProto fdecl
					emitted.Push fdecl
				Next
			Next
			Emit "};"
			Return
		Endif
		
		Local bases$=" : public "+superid
		For Local iface:=Eachin classDecl.implments
			bases+=",public virtual "+iface.munged
		Next

		Emit "class "+classid+bases+"{"
		Emit "public:"

		'fields
		For Local decl:=Eachin classDecl.Semanted
			Local fdecl:=FieldDecl( decl )
			If fdecl
				Emit TransRefType( fdecl.type )+" "+fdecl.munged+";"
				Continue
			Endif
		Next

		'fields ctor
		Emit classid+"();"

		'methods		
		For Local decl:=Eachin classDecl.Semanted
		
			Local fdecl:=FuncDecl( decl )
			If fdecl
				EmitFuncProto fdecl
				Continue
			Endif
			
			Local gdecl:=GlobalDecl( decl )
			If gdecl
				Emit "static "+TransRefType( gdecl.type )+" "+gdecl.munged+";"
				Continue
			Endif
		Next

		'gc mark
		Emit "void mark();"

		Emit "};"
	End
	
	Method EmitMark( id$,ty:Type,queue? )
	
		If ObjectType( ty ) Or ArrayType( ty )

			'Ignore 'unmanaged' objects...
			If ObjectType( ty ) And Not ty.GetClass().ExtendsObject() Return

			If queue
				Emit "gc_mark_q("+id+");"
			Else
				Emit "gc_mark("+id+");"
			Endif
		Endif

	End
	
	Method EmitClassDecl( classDecl:ClassDecl )

		If classDecl.IsInterface()
			Return
		Endif

		Local classid$=classDecl.munged
		Local superid$=classDecl.superClass.munged
		
		'fields ctor
		BeginLocalScope		
		Emit classid+"::"+classid+"(){"
		For Local decl:=Eachin classDecl.Semanted
			Local fdecl:=FieldDecl( decl )
			If Not fdecl Continue
			Emit TransField(fdecl,Null)+"="+fdecl.init.Trans()+";"
		Next
		Emit "}"
		EndLocalScope
		
		'methods		
		For Local decl:=Eachin classDecl.Semanted
		
			Local fdecl:=FuncDecl( decl )
			If fdecl
				EmitFuncDecl fdecl
				Continue
			Endif
			
			Local gdecl:=GlobalDecl( decl )
			If gdecl
				Emit TransRefType( gdecl.type )+" "+classid+"::"+gdecl.munged+";"
				Continue
			Endif
		Next
		
		'gc_mark
		Emit "void "+classid+"::mark(){"
		If classDecl.superClass 
			Emit classDecl.superClass.munged+"::mark();"
		Endif
		For Local decl:=Eachin classDecl.Semanted
			Local fdecl:=FieldDecl( decl )
			If fdecl EmitMark TransField(fdecl,Null),fdecl.type,True
		Next
		Emit "}"
	
	End
	
	Method TransApp$( app:AppDecl )
	
		app.mainFunc.munged="bbMain"
		
		For Local decl:=Eachin app.imported.Values()
			MungDecl decl
		Next

		For Local decl:=Eachin app.Semanted
		
			MungDecl decl

			Local cdecl:=ClassDecl( decl )
			If Not cdecl Continue
			
			Emit "class "+decl.munged+";"
			
			For Local decl:=Eachin cdecl.Semanted
				MungDecl decl
			Next

		Next
		
		'prototypes/header!
		For Local decl:=Eachin app.Semanted
		
			Local gdecl:=GlobalDecl( decl )
			If gdecl
				Emit "extern "+TransRefType( gdecl.type )+" "+gdecl.munged+";"	'forward reference...
				Continue
			Endif
		
			Local fdecl:=FuncDecl( decl )
			If fdecl
				EmitFuncProto fdecl
				Continue
			Endif
		
			Local cdecl:=ClassDecl( decl )
			If cdecl
				EmitClassProto cdecl
				Continue
			Endif
		Next
		
		'definitions!
		For Local decl:=Eachin app.Semanted
			
			Local gdecl:=GlobalDecl( decl )
			If gdecl
				Emit TransRefType( gdecl.type )+" "+gdecl.munged+";"
				Continue
			Endif
			
			Local fdecl:=FuncDecl( decl )
			If fdecl
				EmitFuncDecl fdecl
				Continue
			Endif

			Local cdecl:=ClassDecl( decl )
			If cdecl
				EmitClassDecl cdecl
				Continue
			Endif
		Next
		
		BeginLocalScope
		Emit "int bbInit(){"
		For Local decl:=Eachin app.semantedGlobals
			Emit TransGlobal( decl )+"="+decl.init.Trans()+";"
		Next
		Emit "return 0;"
		Emit "}"
		EndLocalScope

		Emit "void gc_mark(){"
		For Local decl:=Eachin app.semantedGlobals
			EmitMark TransGlobal( decl ),decl.type,True
		Next
		Emit "}"
		
		Return JoinLines()
	End
	
End

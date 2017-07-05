unit SysTypes;

Interface

Uses
 IdURI, IdGlobal, SysUtils, Classes, ServerUtils, uDWConsts, uDWJSONObject;

Type
 TResultErro = Record
  Status,
  MessageText : String;
End;

TArguments = Array Of String;

Type
 TServerUtils = Class
  Class Function ParseRESTURL        (Const Cmd       : String;
                                      vEncoding       : TEncoding) : TDWParams;
  Class Function Result2JSON         (wsResult  : TResultErro) : String;
  Class Function ParseWebFormsParams (Params          : TStrings;
                                      Const URL       : String;
                                      Var   UrlMethod : String;
                                      vEncoding       : TEncoding) : TDWParams;
End;

Type
 TServerMethods = Class(TComponent)
 Protected
  Function    ReturnIncorrectArgs  : String;
  Function    ReturnMethodNotFound : String;
 Public
  Function    ReplyEvent(SendType   : TSendEvent;
                         Arguments  : TArguments) : String;Overload;Virtual;
  Function    ReplyEvent(SendType   : TSendEvent;
                         Context    : String;
                         Var Params : TDWParams)  : String;Overload;Virtual;
  Constructor Create    (aOwner     : TComponent); Override;
  Destructor  Destroy; Override;
End;

implementation

{ TServerMethods }

// Retorna um array de strings com os parametros vindos da URL
// Ex de Cmd : 'GET /NomedoMetodo/Argumento1/Argumento2/ArgumentoN HTTP/1.1'
Class Function TServerUtils.ParseRESTURL (Const Cmd       : String;
                                          vEncoding       : TEncoding) : TDWParams;
Var
 NewCmd       : String;
 ArraySize,
 iBar1, IBar2,
 Cont         : Integer;
 JSONParam    : TJSONParam;
 Function CountExpression(Value : String; Expression : Char) : Integer;
 Var
  I : Integer;
 Begin
  Result := 0;
  For I := 0 To Length(Value) -1 Do
   Begin
    If Value[I] = Expression Then
      Inc(Result);
   End;
 End;
Begin
 NewCmd    := Cmd;
 If CountExpression(NewCmd, '/') > 0 Then
  Begin
   ArraySize := CountExpression(NewCmd, '/');
//   SetLength(Result, ArraySize);
   Result          := TDWParams.Create;
   Result.Encoding := vEncoding;
   NewCmd    := NewCmd + '/';
   iBar1 := Pos ('/', NewCmd);
   Delete (NewCmd, 1, iBar1);
   For Cont := 0 to ArraySize - 1 Do
    Begin
     iBar2 := Pos ('/', NewCmd);
     JSONParam := TJSONParam.Create(Result.Encoding);
     JSONParam.ParamName := Format('PARAM%d', [Cont +1]);
     JSONParam.SetValue(TIdURI.URLDecode (Copy (NewCmd, 1, iBar2 - 1), IndyTextEncoding (encUTF8)));
     Delete (NewCmd, 1, iBar2);
    End;
  End;
End;

Class Function TServerUtils.ParseWebFormsParams (Params          : TStrings;
                                                 const URL       : String;
                                                 Var   UrlMethod : String;
                                                 vEncoding       : TEncoding) : TDWParams;
Var
 I         : Integer;
 Cmd       : String;
 JSONParam : TJSONParam;
Begin
 // Extrai nome do ServerMethod
 Result          := TDWParams.Create;
 Result.Encoding := vEncoding;
 Cmd       := URL + '/';
 I         := Pos ('/', Cmd);
 Delete(Cmd, 1, I);
 I         := Pos ('/', Cmd);
 UrlMethod := Copy(Cmd, 1, I - 1);
 // Extrai Parametros
 For I := 0 To Params.Count -1 Do
  Begin
   JSONParam := TJSONParam.Create(Result.Encoding);
   JSONParam.FromJSON(Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I]))));
   Result.Add(JSONParam);
  End;
End;

Class Function TServerUtils.Result2JSON (wsResult : TResultErro) : String;
Begin
 Result := '{"STATUS":"' + wsResult.Status + '","MENSSAGE":"' + wsResult.MessageText + '"}';
End;

constructor TServerMethods.Create(aOwner: TComponent);
begin
  inherited;
end;

destructor TServerMethods.Destroy;
begin
  inherited;
end;

Function TServerMethods.ReplyEvent(SendType   : TSendEvent;
                                   Context    : String;
                                   Var Params : TDWParams) : String;
Begin
 //Virtual Function
End;

Function TServerMethods.ReplyEvent(SendType  : TSendEvent;
                                   Arguments : TArguments) : String;
Begin
 //Virtual Function
End;

Function TServerMethods.ReturnIncorrectArgs: String;
Var
 WSResult : TResultErro;
Begin
 WSResult.STATUS      := '-1';
 WSResult.MessageText := 'Total de argumentos menor que o esperado';
 Result               := TServerUtils.Result2JSON(WSResult);
End;

Function TServerMethods.ReturnMethodNotFound: String;
Var
 WSResult : TResultErro;
Begin
 WSResult.STATUS      := '-2';
 WSResult.MessageText := 'Metodo nao encontrado';
 Result               := TServerUtils.Result2JSON(WSResult);
End;

end.

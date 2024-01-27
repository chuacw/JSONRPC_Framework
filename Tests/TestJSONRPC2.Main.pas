{---------------------------------------------------------------------------}
{                                                                           }
{ File:      TestJSONRPC2.Main.pas                                          }
{ Function:  Test unit for JSON RPC 2.0 spec examples                       }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit TestJSONRPC2.Main;

interface

uses
  Winapi.Windows, IdHTTP,
  DUnitX.TestFramework, System.Classes,
  Velthuis.BigDecimals, Velthuis.BigIntegers, System.SysUtils;

{$IF NOT DECLARED(Velthuis.BigDecimals) AND NOT DECLARED(Velthuis.BigIntegers)}
  {$MESSAGE HINT 'Include Velthuis.BigDecimals to automatically enable SendExtended'}
{$ENDIF}

{$IF SizeOf(Extended) >= 10}
  {$DEFINE EXTENDEDHAS10BYTES}
{$ENDIF}

type

  [TestFixture]
  TTestJSONRPCClient = class
  protected
    FHTTP: TIdHTTP;
    FRequestStream, FResponseStream: TMemoryStream;

    function _SendJSON(const AJSON: string): string;
    function _SendJSONThread(const AJSON: string): string;
  public
    [SetupFixture]
    procedure _SetupFixture;

    [Setup]
    procedure _Setup;

    [TearDownFixture]
    procedure _TearDownFixture;

    [Test, TestInOwnThread]
    [TestCase('rpc call with positional parameters', '')]
    /// <summary> rpc call with positional parameters </summary>
    procedure Example1;

    [Test, TestInOwnThread]
    [TestCase('rpc call with named parameters', '')]
    /// <summary> rpc call with named parameters </summary>
    procedure Example2;

    [Test, TestInOwnThread]
    [TestCase('a Notification', '')]
    /// <summary> a Notification </summary>
    procedure Example3;

    [Test, TestInOwnThread]
    [TestCase('rpc call of non-existent method', '')]
    /// <summary> rpc call of non-existent method </summary>
    procedure Example4;

    [Test, TestInOwnThread]
    [TestCase('rpc call with invalid JSON', '')]
    /// <summary> rpc call with invalid JSON </summary>
    procedure Example5;
//
    [Test]
    [TestInOwnThread]
    [TestCase('rpc call with invalid Request object / method name', '')]
    /// <summary> rpc call with invalid Request object </summary>
    procedure Example6;

    [Test]
    [TestInOwnThread]
    [TestCase('rpc call Batch, invalid JSON', '')]
    /// <summary> rpc call Batch, invalid JSON </summary>
    procedure Example7;

    [Test, TestInOwnThread]
    [TestCase('rpc call with an empty Array', '')]
    /// <summary> rpc call with an empty Array </summary>
    procedure Example8;

    [Test]
    [TestInOwnThread]
    [TestCase('rpc call with an invalid Batch (but not empty)','')]
    /// <summary> rpc call with an invalid Batch (but not empty) </summary>
    procedure Example9;

    [Test]
    [TestInOwnThread]
    [TestCase('rpc call Batch', '')]
    /// <summary> rpc call Batch </summary>
    procedure Example10;

    [Test]
    [TestInOwnThread]
    [TestCase('rpc call Batch (all notifications)', '')]
    /// <summary> rpc call Batch (all notifications) </summary>
    procedure Example11;


//    [Test]
//    [TestCase('array of const', '')]
//    /// <summary> The following is not a JSON RPC example
//    procedure Example12;
  end;

implementation

uses
  System.JSON, JSONRPC.JsonUtils;

{ TTestJSONRPCClient }

function TTestJSONRPCClient._SendJSON(const AJSON: string): string;
var
  LBuffer: TBytes;
begin
  LBuffer := TEncoding.UTF8.GetBytes(AJSON);
  FRequestStream.Write(LBuffer, Length(LBuffer));
  FRequestStream.Position := 0;
  FHTTP.Post('http://localhost:8083/', FRequestStream, FResponseStream);
  SetLength(LBuffer, FResponseStream.Size);
  FResponseStream.Position := 0;
  FResponseStream.Read(LBuffer, Length(LBuffer));
  Result := TEncoding.UTF8.GetString(LBuffer);
end;

function TTestJSONRPCClient._SendJSONThread(const AJSON: string): string;
var
  LBuffer: TBytes;
begin
  LBuffer := TEncoding.UTF8.GetBytes(AJSON);
  var LRequestStream := TMemoryStream.Create;
  try
    LRequestStream.Write(LBuffer, Length(LBuffer));
    LRequestStream.Position := 0;
    var LResponseStream := TMemoryStream.Create;
    try
      var LHTTP := TIdHTTP.Create;
      try
        LHTTP.Post('http://localhost:8083/', LRequestStream, LResponseStream);
        SetLength(LBuffer, LResponseStream.Size);
        LResponseStream.Position := 0;
        LResponseStream.Read(LBuffer, Length(LBuffer));
      finally
        LHTTP.Free;
      end;
    finally
      LResponseStream.Free;
    end;
    Result := TEncoding.UTF8.GetString(LBuffer);
  finally
    LRequestStream.Free;
  end;
end;

procedure TTestJSONRPCClient._Setup;
begin
  FResponseStream.Size := 0;
  FRequestStream.Size  := 0;
end;

procedure TTestJSONRPCClient._SetupFixture;
begin
  FHTTP := TIdHTTP.Create;
  FResponseStream := TMemoryStream.Create;
  FRequestStream := TMemoryStream.Create;
end;

procedure TTestJSONRPCClient._TearDownFixture;
begin
  FRequestStream.Free;
  FResponseStream.Free;
  FHTTP.Free;
end;

procedure TTestJSONRPCClient.Example1;
begin
  // 1.1
  var Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}');
  Assert.IsTrue(SameJSON('{"jsonrpc":"2.0","result":19,"id":1}', Response));

  // 1.2
  Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "subtract", "params": [23, 42], "id": 2}');
  Assert.IsTrue(SameJSON('{"jsonrpc":"2.0","result":-19,"id":2}', Response));
end;

procedure TTestJSONRPCClient.Example2;
begin
  var Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 3}');
  Assert.IsTrue(SameJSON('{"jsonrpc": "2.0","result":19,"id":3}', Response));

  Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "subtract", "params": {"minuend": 42, "subtrahend": 23}, "id": 4}');
  Assert.IsTrue(SameJSON('{"jsonrpc": "2.0", "result": 19, "id": 4}', Response));
end;

procedure TTestJSONRPCClient.Example3;
begin
  var Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]}');
  Assert.IsEmpty(Response);

  Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "foobar"}');
  Assert.IsTrue(
    SameJSON('{"jsonrpc":"2.0","error":{"message":"Method not found","code":-32601},"id":null}',
      Response));
end;

procedure TTestJSONRPCClient.Example4;
begin
  var Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "foobar", "id": "1"}');
  Assert.IsTrue(
    SameJSON('{"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "1"}',
      Response));
end;

procedure TTestJSONRPCClient.Example5;
begin
  var Response := _SendJSONThread('{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]');
  Assert.IsTrue(
    SameJSON('{"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"},"id":null}',
      Response));
end;

procedure TTestJSONRPCClient.Example6;
begin
  var Response := _SendJSONThread('{"jsonrpc": "2.0", "method": 1, "params": "bar"}');
  Assert.IsTrue(
    SameJSON('{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}',
      Response));
end;

procedure TTestJSONRPCClient.Example7;
begin
  var Response := _SendJSONThread(
'''
[
  {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
  {"jsonrpc": "2.0", "method"
]
''');
  Assert.IsTrue(
    SameJSON('{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}',
      Response));
end;

procedure TTestJSONRPCClient.Example8;
begin
  var Response := _SendJSONThread('[]');
  Assert.IsTrue(
    SameJSON('{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}',
      Response));
end;

procedure TTestJSONRPCClient.Example9;
begin
  var Response := _SendJSONThread('[1]');
  Assert.IsTrue(
    SameJSON('[{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}]',
      Response));
end;

procedure TTestJSONRPCClient.Example10;
begin

  var Response := _SendJSONThread('''
[
        {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
        {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]},
        {"jsonrpc": "2.0", "method": "subtract", "params": [42,23], "id": "2"},
        {"foo": "boo"},
        {"jsonrpc": "2.0", "method": "foo.get", "params": {"name": "myself"}, "id": "5"},
        {"jsonrpc": "2.0", "method": "get_data", "id": "9"}
]
''');
  Assert.IsTrue(
    SameJSON('''
[
        {"jsonrpc": "2.0", "result": 7, "id": "1"},
        {"jsonrpc": "2.0", "result": 19, "id": "2"},
        {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
        {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "5"},
        {"jsonrpc": "2.0", "result": ["hello", 5], "id": "9"}
]
''',
      Response));
end;

procedure TTestJSONRPCClient.Example11;
begin
  var Response := _SendJSONThread(
'''
[
        {"jsonrpc": "2.0", "method": "notify_sum", "params": [1,2,4]},
        {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]}
]
'''
  );
  Assert.IsTrue(SameJSON('', Response));
end;

//procedure TTestJSONRPCClient.Example12;
//begin
//  var Response := _SendJSON('{"jsonrpc": "2.0", "method": "send_data", params: [["hello", 5, 4.0, True]], "id": "9"}');
//end;

initialization
  TDUnitX.RegisterTestFixture(TTestJSONRPCClient);
end.

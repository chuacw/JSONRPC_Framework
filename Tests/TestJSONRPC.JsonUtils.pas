unit TestJSONRPC.JsonUtils;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TTestJSONRPCClient = class
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('ArrayToJSONArray','')]
    procedure TestArrayToJSONArray;

  end;

implementation

uses
  JSONRPC.JsonUtils, DUnitX.Assert;

{ TTestJSONRPCClient }

procedure TTestJSONRPCClient.Setup;
begin
end;

procedure TTestJSONRPCClient.TearDown;
begin
end;

procedure TTestJSONRPCClient.TestArrayToJSONArray;
type
  TMyArray = TArray<Integer>;
begin
  var LArray1: TMyArray := [1, 2, 3, 4, 5];
  var LResult := ArrayToJSONArray(LArray1, TypeInfo(TMyArray)).ToJSON;
  Assert.AreEqual(LResult, '[1,2,3,4,5]', True, 'ArrayToJSONArray issue');
end;

end.

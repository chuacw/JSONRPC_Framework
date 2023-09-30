unit TestJSONRPC.TestEthereumClient;

interface

uses
  DUnitX.TestFramework, JSONRPC.ServerBase.Runner;

type

  [TestFixture]
  TTestEthereumJSONRPC = class
  protected
    FServerRunner: TJSONRPCServerRunner;
    FStartPort: Integer;
  public
    [SetupFixture]
    procedure Setup;

    [TearDownFixture]
    procedure TearDown;

    // Sample Methods
    // Simple single Test
    [Test]
    procedure Test1;

    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
  end;

implementation

uses
  JSONRPC.ServerIdHTTP.Runner, System.SysUtils;

procedure TTestEthereumJSONRPC.Setup;
begin
// Set up internal server
  FServerRunner := TJSONRPCServerIdHTTPRunner.Create;
  var LPortSet: Boolean;
  FStartPort := 8085;
  repeat
    LPortSet := FServerRunner.CheckPort(FStartPort) > 0;
    if not LPortSet then
      Inc(FStartPort);
  until LPortSet;
  FServerRunner.Host := 'localhost';
  FServerRunner.StartServer(FStartPort);

// Set up RPC client
  var LServerURL := Format('http://localhost:%d', [FStartPort]);
  FSomeRPC := GetSomeJSONRPC(LServerURL);
end;

procedure TTestEthereumJSONRPC.TearDown;
begin
end;

procedure TTestEthereumJSONRPC.Test1;
begin
end;

procedure TTestEthereumJSONRPC.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TTestEthereumJSONRPC);

end.

program TestJSONRPC;

(*
The following should be in the first part of the unit clause
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
*)
{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  System.SysUtils,
  JSONRPC.JsonUtils in '..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.User.SomeTypes in '..\Common\JSONRPC.User.SomeTypes.pas',
  JSONRPC.RIO in '..\Common\JSONRPC.RIO.pas',
  JSONRPC.InvokeRegistry in '..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Types in '..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.Consts in '..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.User.ServerImpl in '..\Server\JSONRPC.User.ServerImpl.pas',
  TestJSONRPC.Client in 'TestJSONRPC.Client.pas',
  JSONRPC.ServerBase.Runner in '..\Server\JSONRPC.ServerBase.Runner.pas',
  JSONRPC.User.SomeTypes.Impl in '..\Client\JSONRPC.User.SomeTypes.Impl.pas',
  JSONRPC.ServerIdHTTP.Runner in '..\Server\JSONRPC.ServerIdHTTP.Runner.pas',
  JSONRPC.TransportWrapper.HTTP in '..\Common\JSONRPC.TransportWrapper.HTTP.pas';

{$IFNDEF TESTINSIGHT}
// {$IFNDEF TESTINSIGHT} // in case the IDE removes the above, this is what was there
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    // Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.

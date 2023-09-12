program TestIncAMonth;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
{$STACKFRAMES OFF}
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
uses
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  System.Math, System.Threading, System.Skia, System.Types, Winapi.D2D1,
  System.SysUtils, System.Classes, Vcl.Clipbrd,
  TestIncAMonth.Main in 'TestIncAMonth.Main.pas';

procedure IncAMonth(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);
var
  DayTable: PDayTable;
  Sign: Integer;
  NegMonths: Integer;
begin
  NegMonths := -12;
  if NumberOfMonths >= 0 then Sign := 1 else Sign := -1;
  Year := Year + (NumberOfMonths div 12);
  NumberOfMonths := NumberOfMonths mod 12;
  Month := Month + NumberOfMonths;
  if Word(Month-1) > 11 then    // if Month <= 0, word(Month-1) > 11)
  begin
    Year := Year + Sign;
    Month := Month + (-12 * Sign);
  end;
  DayTable := @MonthDays[IsLeapYear(Year)];
  if Day > DayTable^[Month] then Day := DayTable^[Month];
end;

procedure TestOutput;
begin
  var FailCount := 0;
  for var I := 0 to 13 do
    begin
      var Y: Word := 2023; var M: Word := 12; var D: Word := 1;
      WriteLn(Format('Test Case starts with, Y: %d M: %d D: %d', [Y, M, D]));
      IncAMonth(Y, M, D, I);
      if (M > 12) or (M < 1) then
        begin
          WriteLn(Format('Test Case issue, Y: %d M: %d D: %d', [Y, M, D]));
          Inc(FailCount);
        end;
      WriteLn('--------------------------------------------------------------');
    end;
  for var I := -23 to -1 do
    begin
      var Y: Word := 2023; var M: Word := 1; var D: Word := 1;
      WriteLn(Format('Test Case starts with, Y: %d M: %d D: %d', [Y, M, D]));
      IncAMonth(Y, M, D, I);
      if (M > 12) or (M < 1) then
        begin
          WriteLn(Format('Test Case issue, Y: %d M: %d D: %d', [Y, M, D]));
          Inc(FailCount);
        end;
      WriteLn('--------------------------------------------------------------');
    end;
  Writeln('Total  failed: ', FailCount);
    var ClassDecl:= TStringList.Create;
    var Sign := 1;
    ClassDecl.Add(
'''
type

  [TestFixture]
  TestCase = class
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;
''');

    var Lines := TStringList.Create;
    for var I := 1 to 20000 do
      begin
        var LExpected := -I * Sign;
        var Line := Format(
          '''

          procedure TestCase.TestMonth%0:d(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);
          var
            Sign: Integer;
          begin
            if NumberOfMonths >= 0 then Sign := 1 else Sign := -1;
            Year := Year + (NumberOfMonths div 12);
            NumberOfMonths := NumberOfMonths mod 12;
            Month := Month + NumberOfMonths;   // Empty
            if Word(Month-1) > 11 then
            begin
              Year := Year + Sign;
              Month := Month + (-%0:d * Sign);
            end;
            Assert.AreEqual(%2:d, Month, 'TestMonth%0:d');
          end;
          ''', [I, Abs(LExpected), I-1]);
        Lines.Add(Line);

        ClassDecl.Add(Format(
          '''

              [Test]
              [TestCase('TestMonth%0:d', '2005,2,1,-3')]
              procedure TestMonth%0:d(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);
          ''', [I])
        );
      end;

    ClassDecl.Add(
      '''
        end;

      implementation

      { TestCase }

      procedure TestCase.Setup;
      begin
      end;

      procedure TestCase.TearDown;
      begin
      end;
      '''
    );

  ClassDecl.AddStrings(Lines);

  Clipboard.AsText := ClassDecl.Text;
  Lines.Free;
  ClassDecl.Free;
end;


{$IFNDEF TESTINSIGHT}
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
    var Matrix3X2F: TD2DMatrix3X2F;
    var X := Round(Matrix3X2F.Determinant);
    WriteLn(X);
    TestOutput;
    TSkPath.ConvertConicToQuads(TPointF.Zero, TPointF.Zero, TPointF.Zero, 0, 3);

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      begin
        WriteLn(Format('%d failures out of %d test cases', [results.FailureCount, results.TestCount]));
        System.ExitCode := EXIT_ERRORS;
      end;

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

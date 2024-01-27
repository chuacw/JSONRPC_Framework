program README;

uses
  System.SysUtils,
  System.JSON,
  System.Rtti,
  JSONRPC.Common.Types in 'Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.Consts in 'Common\JSONRPC.Common.Consts.pas',
  JSONRPC.Common.RecordHandlers in 'Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.JsonUtils in 'Common\JSONRPC.JsonUtils.pas';

function get_data: TConstArray;
begin
  Result := CreateConstArray(['hello', 5]);
end;


procedure Main;
begin
  var data := get_data;
  var LValue := TValue.From(data);
  var LJSONArray := ValueToJSONArray(LValue, TypeInfo(TConstArray));
  try
    WriteLn(LJSONArray.ToJSON);
    // let's assume it's a TConstArray to simplify conversion
    DeserializeJSON(LJSONArray, TypeInfo(TConstArray), LValue);
  finally
    LJSONArray.Free;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  Main;
end.

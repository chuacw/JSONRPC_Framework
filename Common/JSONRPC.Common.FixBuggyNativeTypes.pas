unit JSONRPC.Common.FixBuggyNativeTypes;

interface

uses
  Velthuis.BigDecimals;

function FixedFloatToJson(const Value: Extended): string;

implementation

uses
  System.SysUtils, System.JSON;

function FixedFloatToJson(const Value: Extended): string;
var
  Buffer: array[0..63] of Char;
  L: Integer;
begin
  L := FloatToText(Buffer, Value, fvExtended, ffGeneral, 17, 0, GetJSONFormat);
  Buffer[L] := #0;
  if StrScan(Buffer, '.') = nil then
  begin
    Buffer[L] := '.';
    Buffer[L + 1] := '0';
    Inc(L, 2);
  end;
  SetString(Result, Buffer, L);
end;

end.



































// chuacw, Jun 2023


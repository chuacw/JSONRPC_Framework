unit JSONRPC.Common.FixBuggyNativeTypes;

interface

uses
  Velthuis.BigDecimals;

function FixedFloatToJson(const Value: Double): string;

implementation

uses
  System.SysUtils, System.JSON;

function FixedFloatToJson(const Value: Double): string;
var
  Buffer: array[0..63] of Char;
  L: Integer;
  E: Extended;
begin
  E := Value;
  L := FloatToText(Buffer, E, fvExtended, ffGeneral, 15, 0, GetJSONFormat);
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

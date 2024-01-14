{---------------------------------------------------------------------------}
{                                                                           }
{ File:      JSONRPC.Common.FixBuggyNativeTypes.pas                         }
{ Function:  Fixes FloatToJson                                              }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.Common.FixBuggyNativeTypes;

interface

const
  DelphiAthens        = 36.0;
  Delphi120           = 36.0;

function FixedFloatToJson(const Value: Extended): string;
{$IF RTLVersion >= Delphi120 }
  inline;
{$ENDIF}

implementation

uses
{$IF RTLVersion < Delphi120 }
  System.SysUtils,
{$ENDIF}
  System.JSON;

function FixedFloatToJson(const Value: Extended): string;
{$IF RTLVersion < Delphi120 } // System
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
{$ELSE}
begin
  Result := System.JSON.FloatToJson(Value);
{$ENDIF}
end;

end.



































// chuacw, Jun 2023


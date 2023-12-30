unit JSONRPC.Wizard.Consts;

interface

const

  SInvalidIdentifierFmt: string = 'Invalid identifier: "%s"';

  SAuthenticationSource: string =
'''
  if (AUserName <> '') or (APassword <> '') then
    begin
      LJSONRPCWrapper.OnBeforeInitializeHeaders := procedure (var VNetHeaders: TNetHeaders)
      begin
        var LUserNamePassword := Format('%s:%s', [AUserName, APassword]);
        VNetHeaders := [TNameValuePair.Create('Authorization', 'Basic ' +
          TNetEncoding.Base64String.Encode(LUserNamePassword))];
      end;
    end;
''';

  SMethodSource: string =
'''
unit %s;
{$CODEALIGN 16}

interface

uses
// Helpful units
//  JSONRPC.Common.Types, System.Classes, System.JSON.Serializers,
  JSONRPC.RIO, %s;

%s;

implementation

uses
// Helpful units
//  System.JSON, System.Rtti,
  JSONRPC.InvokeRegistry%s;

%2:s;
begin
  RegisterJSONRPCWrapper(TypeInfo(%4:s));
  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);
%s
  Result := LJSONRPCWrapper as %4:s;
end;

end.
''';

  SInterfaceUnitSource: string =
'''
unit %s;

interface

uses
  JSONRPC.RIO;

type

  %s = interface(IJSONRPCMethods)
    ['%s']
  end;

implementation

uses
  JSONRPC.InvokeRegistry;

initialization
  InvRegistry.RegisterInterface(TypeInfo(%1:s));
end.
''';

implementation

end.

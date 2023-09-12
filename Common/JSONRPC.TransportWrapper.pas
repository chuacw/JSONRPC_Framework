unit JSONRPC.TransportWrapper;

interface

uses
  System.Classes, System.Net.URLClient;

type

  TJSONRPCTransportWrapper = class
  private
    function GetConnectionTimeout: Integer; virtual; abstract;
    function GetResponseTimeout: Integer; virtual; abstract;
    function GetSendTimeout: Integer; virtual; abstract;
    procedure SetConnectionTimeout(const Value: Integer); virtual; abstract;
    procedure SetResponseTimeout(const Value: Integer); virtual; abstract;
    procedure SetSendTimeout(const Value: Integer); virtual; abstract;
  public
    procedure Post(const AURL: string; const ASource, AResponseContent: TStream;
      const AHeaders: TNetHeaders); virtual; abstract;
    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
  end;

implementation

end.

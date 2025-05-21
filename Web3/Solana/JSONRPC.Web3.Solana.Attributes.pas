unit JSONRPC.Web3.Solana.Attributes;

interface

type

  EnumAsAttribute = class(TCustomAttribute)
  protected
    FIndex: Integer;
    FName: string;
  public
    constructor Create(AIndex: Integer; const AName: string);
    property Index: Integer read FIndex;
    property EnumName: string read FName;
  end;

implementation

{ EnumAsAttribute }

constructor EnumAsAttribute.Create(AIndex: Integer; const AName: string);
begin
  FIndex := AIndex;
  FName := AName;
end;

end.

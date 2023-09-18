unit JSONRPC.Web3.Aptos.Common.Types;

interface

uses
  System.JSON.Serializers;

type
  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TError = record
  private
    Fcode: Integer;
    Fmessage: string;
    Fvm_error_code: string;
  public
    property code: Integer read Fcode write Fcode;
    property message: string read Fmessage write Fmessage;
    property vm_error_code: string read Fvm_error_code write Fvm_error_code;
  end align 16;

implementation

end.

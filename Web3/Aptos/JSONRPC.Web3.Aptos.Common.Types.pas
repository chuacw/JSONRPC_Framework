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

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TBlocksByHeightResult = record
  private
    Fblock_height: string;
    Fblock_hash: string;
    Fblock_timestamp: string;
    Ffirst_version: string;
    Flast_version: string;
    Ftransactions: string;
  public
    property block_height: string read Fblock_height write Fblock_height;
    property block_hash: string read Fblock_hash write Fblock_hash;
    property block_timestamp: string read Fblock_timestamp write Fblock_timestamp;
    property first_version: string read Ffirst_version write Ffirst_version;
    property last_version: string read Flast_version write Flast_version;
    property transactions: string read Ftransactions write Ftransactions;
  end;

implementation

end.

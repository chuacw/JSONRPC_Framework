unit Web3.Common.Types;

interface

type

//  HexNumber = record
//  private
//    FValue: string;
//  public
//    class operator Implicit(const AHexNumber: HexNumber): string;
//    class operator Implicit(const ANumber: string): HexNumber;
//
//    class operator Implicit(const AHexNumber: HexNumber): Integer;
//    class operator Implicit(const ANumber: Integer): HexNumber;
//
//    class operator Implicit(const ANumber: Int64): HexNumber;
//    class operator Implicit(const AHexNumber: HexNumber): Int64;
//
//    class operator Implicit(const ANumber: UInt64): HexNumber;
//    class operator Implicit(const AHexNumber: HexNumber): UInt64;
//  end;

    HexNumber = string;

//  Web3Address = record
//  private
//    FValue: string;
//  public
//    class operator Implicit(const AAddress: string): Web3Address;
//    class operator Implicit(const AWeb3Address: Web3Address): string;
//  end;

  Web3Address = string;
  Hash = string;
  NonceType = string;

implementation

uses
  System.SysUtils;

{ HexNumber }

//class operator HexNumber.Implicit(const AHexNumber: HexNumber): string;
//begin
//  Result := AHexNumber.FValue;
//end;
//
//class operator HexNumber.Implicit(const ANumber: string): HexNumber;
//begin
//  Result.FValue := ANumber;
//end;
//
//class operator HexNumber.Implicit(const ANumber: UInt64): HexNumber;
//begin
//  Result.FValue := Format('0x%x', [ANumber]);
//end;
//
//class operator HexNumber.Implicit(const ANumber: Integer): HexNumber;
//begin
//  Result.FValue := Format('0x%x', [ANumber]);
//end;
//
//class operator HexNumber.Implicit(const ANumber: Int64): HexNumber;
//begin
//  Result.FValue := Format('0x%x', [ANumber]);
//end;
//
//class operator HexNumber.Implicit(const AHexNumber: HexNumber): Integer;
//begin
//  Result := StrToInt(AHexNumber.FValue);
//end;
//
//class operator HexNumber.Implicit(const AHexNumber: HexNumber): Int64;
//begin
//  Result := StrToInt64(AHexNumber.FValue);
//end;
//
//class operator HexNumber.Implicit(const AHexNumber: HexNumber): UInt64;
//begin
//  Result := StrToUInt64(AHexNumber.FValue);
//end;

{ Web3Address }

//class operator Web3Address.Implicit(const AWeb3Address: Web3Address): string;
//begin
//  Result := AWeb3Address.FValue;
//end;
//
//class operator Web3Address.Implicit(const AAddress: string): Web3Address;
//begin
//  Result.FValue := AAddress;
//end;

end.

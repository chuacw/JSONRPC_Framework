{---------------------------------------------------------------------------}
{                                                                           }
{ File:       JSONRPC.Common.Consts.pas                                     }
{ Function:   Common constant declarations                                  }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.Common.Consts;

{$ALIGN 16}
{$CODEALIGN 16}

interface

const

  STrue: string    = 'True';

  SJSONRPC: string = 'jsonrpc';
  SID: string      = 'id';
  SRESULT: string  = 'result';
  SMETHOD: string  = 'method';

  SPARAMS: string  = 'params';

  SERROR: string       = 'error';
  SCODE: string        = 'code';
  SMESSAGE: string     = 'message';
//  SMETHODNAME: string  = 'method';
  SPARAM: string       = 'parameter';

  SCLASSNAME: string = 'class';

  SMethodNotFound: string      = 'Method not found';
  SMDAIndexNotFound: string    = 'MDA Index not found';
  SParseError: string          = 'Parse error';
  SInvalidRequest: string      = 'Invalid Request';
  SInternalServerError: string = 'Internal server error';

  SApplicationJson: string     = 'application/json';
  SApplicationJsonRPC: string  = 'application/json-rpc';
  SHeadersAccept: string       = 'accept';
  SHeadersContentType: string  = 'content-type';
  CHeadersContentLength: string  = 'Content-Length';
  
  CParseErrorInvalidCharacter    = -32702;
  CParseErrorUnsupportedEncoding = -32701;
  CParseErrorNotWellFormed       = -32700;

  CInternalError                 = -32603;
  CInvalidMethodParams           = -32602;
  CMethodNotFound                = -32601;
  CInvalidRequest                = -32600;

  CApplicationError              = -32500;
  CSystemError                   = -32400;
  CTransportError                = -32300;

  CServerError099                = -32099;
  CServerError001                = -32001;
  CMDAIndexNotFound              = -32000;

type

  TCompilerVersion = record
  const
    Delphi2009       = 20.0;
    Delphi2010       = 21.0;
    DelphiXE         = 22.0;
    DelphiXE2        = 23.0;
    DelphiXE3        = 24.0;
    DelphiXE4        = 25.0;
    DelphiXE5        = 26.0;
    AppMethod1       = 26.5;
    DelphiXE6        = 27.0;
    DelphiXE7        = 28.0;
    DelphiXE8        = 29.0;

    Delphi10         = 30.0;
    Delphi100        = 30.0;
    DelphiSeattle    = 30.0;

    Delphi101        = 31.0;
    DelphiBerlin     = 31.0;

    Delphi102        = 32.0;
    DelphiTokyo      = 32.0;

    Delphi103        = 33.0;
    DelphiRio        = 33.0;

    Delphi104        = 34.0;
    DelphiSydney     = 34.0;

    Delphi110        = 35.0;
    DelphiAlexandria = 35.0;

    DelphiAthens     = 36.0;
    Delphi120        = 36.0;
  end;

  TRTLVersion = record
  const
    Delphi2009          = 20.0;
    Delphi2010          = 21.0;
    DelphiXE            = 22.0;
    DelphiXE2           = 23.0;
    DelphiXE3           = 24.0;
    DelphiXE4           = 25.0;
    DelphiXE5           = 26.0;
    AppMethod1          = 26.5;
    DelphiXE6           = 27.0;
    DelphiXE7           = 28.0;
    DelphiXE8           = 29.0;

    Delphi10            = 30.0;
    Delphi100           = 30.0;
    DelphiSeattle       = 30.0;

    Delphi101           = 31.0;
    DelphiBerlin        = 31.0;

    Delphi102           = 32.0;
    DelphiTokyo         = 32.0;

    Delphi103           = 33.0;
    DelphiRio           = 33.0;

    Delphi104           = 34.0;
    DelphiSydney        = 34.0;

    Delphi110           = 35.0;
    DelphiAlexandria    = 35.0;

    DelphiAthens        = 36.0;
    Delphi120           = 36.0;
  end;

const
  CompilerVersionDelphi2009       = TCompilerVersion.Delphi2009;
  CompilerVersionDelphi2010       = TCompilerVersion.Delphi2010;
  CompilerVersionDelphiXE         = TCompilerVersion.DelphiXE;
  CompilerVersionDelphiXE2        = TCompilerVersion.DelphiXE2;
  CompilerVersionDelphiXE3        = TCompilerVersion.DelphiXE3;
  CompilerVersionDelphiXE4        = TCompilerVersion.DelphiXE4;
  CompilerVersionDelphiXE5        = TCompilerVersion.DelphiXE5;
  ComplierVersionAppMethod1       = TCompilerVersion.AppMethod1;
  CompilerVersionDelphiXE6        = TCompilerVersion.DelphiXE6;
  CompilerVersionDelphiXE7        = TCompilerVersion.DelphiXE7;
  CompilerVersionDelphiXE8        = TCompilerVersion.DelphiXE8;
  CompilerVersionDelphi10         = TCompilerVersion.Delphi10;
  CompilerVersionDelphi100        = TCompilerVersion.Delphi100;
  CompilerVersionDelphiSeattle    = TCompilerVersion.DelphiSeattle;
  CompilerVersionDelphi101        = TCompilerVersion.Delphi101;
  CompilerVersionDelphiBerlin     = TCompilerVersion.DelphiBerlin;
  CompilerVersionDelphi102        = TCompilerVersion.Delphi102;
  CompilerVersionDelphiTokyo      = TCompilerVersion.DelphiTokyo;
  CompilerVersionDelphi103        = TCompilerVersion.Delphi103;
  CompilerVersionDelphiRio        = TCompilerVersion.DelphiRio;
  CompilerVersionDelphi104        = TCompilerVersion.Delphi104;
  CompilerVersionDelphiSydney     = TCompilerVersion.DelphiSydney;
  CompilerVersionDelphi110        = TCompilerVersion.Delphi110;
  CompilerVersionDelphiAlexandria = TCompilerVersion.DelphiAlexandria;
  CompilerVersionDelphiAthens     = TCompilerVersion.DelphiAthens;
  CompilerVersionDelphi120        = TCompilerVersion.Delphi120;
  // RTL versions
  RTLVersionDelphi2009          = TRTLVersion.Delphi2009;
  RTLVersionDelphi2010          = TRTLVersion.Delphi2010;
  RTLVersionDelphiXE            = TRTLVersion.DelphiXE;
  RTLVersionDelphiXE2           = TRTLVersion.DelphiXE2;
  RTLVersionDelphiXE3           = TRTLVersion.DelphiXE3;
  RTLVersionDelphiXE4           = TRTLVersion.DelphiXE4;
  RTLVersionDelphiXE5           = TRTLVersion.DelphiXE5;
  RTLVersionAppMethod1          = TRTLVersion.AppMethod1;
  RTLVersionDelphiXE6           = TRTLVersion.DelphiXE6;
  RTLVersionDelphiXE7           = TRTLVersion.DelphiXE7;
  RTLVersionDelphiXE8           = TRTLVersion.DelphiXE8;
  RTLVersionDelphi10            = TRTLVersion.Delphi10;
  RTLVersionDelphi100           = TRTLVersion.Delphi100;
  RTLVersionDelphiSeattle       = TRTLVersion.DelphiSeattle;
  RTLVersionDelphi101           = TRTLVersion.Delphi101;
  RTLVersionDelphiBerlin        = TRTLVersion.DelphiBerlin;
  RTLVersionDelphi102           = TRTLVersion.Delphi102;
  RTLVersionDelphiTokyo         = TRTLVersion.DelphiTokyo;
  RTLVersionDelphi103           = TRTLVersion.Delphi103;
  RTLVersionDelphiRio           = TRTLVersion.DelphiRio;
  RTLVersionDelphi104           = TRTLVersion.Delphi104;
  RTLVersionDelphiSydney        = TRTLVersion.DelphiSydney;
  RTLVersionDelphi110           = TRTLVersion.Delphi110;
  RTLVersionDelphiAlexandria    = TRTLVersion.DelphiAlexandria;

  RTLVersionDelphiAthens        = TRTLVersion.DelphiAthens;
  RTLVersionDelphi120           = TRTLVersion.Delphi120;

implementation

end.



































// chuacw, Jun 2023


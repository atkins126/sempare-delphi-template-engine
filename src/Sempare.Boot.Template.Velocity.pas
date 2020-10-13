(*%****************************************************************************
 *  ___                                             ___               _       *
 * / __|  ___   _ __    _ __   __ _   _ _   ___    | _ )  ___   ___  | |_     *
 * \__ \ / -_) | '  \  | '_ \ / _` | | '_| / -_)   | _ \ / _ \ / _ \ |  _|    *
 * |___/ \___| |_|_|_| | .__/ \__,_| |_|   \___|   |___/ \___/ \___/  \__|    *
 *                     |_|                                                    *
 ******************************************************************************
 *                                                                            *
 *                        VELOCITY TEMPLATE ENGINE                            *
 *                                                                            *
 *                                                                            *
 *          https://www.github.com/sempare/sempare.boot.velocity.oss          *
 ******************************************************************************
 *                                                                            *
 * Copyright (c) 2019 Sempare Limited,                                        *
 *                    Conrad Vermeulen <conrad.vermeulen@gmail.com>           *
 *                                                                            *
 * Contact: info@sempare.ltd                                                  *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *   http://www.apache.org/licenses/LICENSE-2.0                               *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 *                                                                            *
 ****************************************************************************%*)
unit Sempare.Boot.Template.Velocity;

interface

uses
  System.Classes,
  System.SysUtils,
  Sempare.Boot.Template.Velocity.Common,
  Sempare.Boot.Template.Velocity.Context,
  Sempare.Boot.Template.Velocity.AST,
  Sempare.Boot.Template.Velocity.Parser;

const
  eoStripRecurringSpaces = TVelocityEvaluationOption.eoStripRecurringSpaces;
  eoConvertTabsToSpaces = TVelocityEvaluationOption.eoConvertTabsToSpaces;
  eoNoDefaultFunctions = TVelocityEvaluationOption.eoNoDefaultFunctions;
  eoNoPosition = TVelocityEvaluationOption.eoNoPosition;
  eoEvalEarly = TVelocityEvaluationOption.eoEvalEarly;
  eoEvalVarsEarly = TVelocityEvaluationOption.eoEvalVarsEarly;
  eoStripRecurringNewlines = TVelocityEvaluationOption.eoStripRecurringNewlines;
  eoTrimLines = TVelocityEvaluationOption.eoTrimLines;
  // eoDebug = TVelocityEvaluationOption.eoDebug;
  eoPrettyPrint = TVelocityEvaluationOption.eoPrettyPrint;
  eoRaiseErrorWhenVariableNotFound = TVelocityEvaluationOption.eoRaiseErrorWhenVariableNotFound;
  eoReplaceNewline = TVelocityEvaluationOption.eoReplaceNewline;

type
  TVelocityEvaluationOptions = Sempare.Boot.Template.Velocity.Context.TVelocityEvaluationOptions;
  TVelocityEvaluationOption = Sempare.Boot.Template.Velocity.Context.TVelocityEvaluationOption;
  TVelocityValue = Sempare.Boot.Template.Velocity.AST.TVelocityValue;
  IVelocityContext = Sempare.Boot.Template.Velocity.Context.IVelocityContext;
  IVelocityTemplate = Sempare.Boot.Template.Velocity.AST.IVelocityTemplate;
  IVelocityFunctions = Sempare.Boot.Template.Velocity.Context.IVelocityFunctions;
  TVelocityTemplateResolver = Sempare.Boot.Template.Velocity.Context.TVelocityTemplateResolver;
  TVelocityEncodeFunction = Sempare.Boot.Template.Velocity.Common.TVelocityEncodeFunction;
  IVelocityVariables = Sempare.Boot.Template.Velocity.Common.IVelocityVariables;
  TUTF8WithoutPreambleEncoding = Sempare.Boot.Template.Velocity.Context.TUTF8WithoutPreambleEncoding;

  Velocity = class
  public
    class function Context(AOptions: TVelocityEvaluationOptions = []): IVelocityContext; inline; static;
    class function Parser(AContext: IVelocityContext): IVelocityParser; overload; inline; static;
    class function Parser(): IVelocityParser; overload; inline; static;
    class function PrettyPrint(ATemplate: IVelocityTemplate): string; inline; static;

    // EVAL output to stream

    class procedure Eval(const ATemplate: string; const AStream: TStream; const AOptions: TVelocityEvaluationOptions = []); overload; static;
    class procedure Eval<T>(const ATemplate: string; const AValue: T; const AStream: TStream; const AOptions: TVelocityEvaluationOptions = []); overload; static;
    class procedure Eval<T>(ATemplate: IVelocityTemplate; const AValue: T; const AStream: TStream; const AOptions: TVelocityEvaluationOptions = []); overload; static;
    class procedure Eval(ATemplate: IVelocityTemplate; const AStream: TStream; const AOptions: TVelocityEvaluationOptions = []); overload; static;
    class procedure Eval<T>(AContext: IVelocityContext; ATemplate: IVelocityTemplate; const AValue: T; const AStream: TStream); overload; static;
    class procedure Eval<T>(AContext: IVelocityContext; const ATemplate: string; const AValue: T; const AStream: TStream); overload; static;
    class procedure Eval(AContext: IVelocityContext; const ATemplate: string; const AStream: TStream); overload; static;
    class procedure Eval(AContext: IVelocityContext; ATemplate: IVelocityTemplate; const AStream: TStream); overload; static;

    // EVAL returning string

    class function Eval(const ATemplate: string; const AOptions: TVelocityEvaluationOptions = []): string; overload; static;
    class function Eval<T>(const ATemplate: string; const AValue: T; const AOptions: TVelocityEvaluationOptions = []): string; overload; static;
    class function Eval<T>(ATemplate: IVelocityTemplate; const AValue: T; const AOptions: TVelocityEvaluationOptions = []): string; overload; static;
    class function Eval(ATemplate: IVelocityTemplate; const AOptions: TVelocityEvaluationOptions = []): string; overload; static;

    class function Eval<T>(AContext: IVelocityContext; ATemplate: IVelocityTemplate; const AValue: T): string; overload; static;
    class function Eval<T>(AContext: IVelocityContext; const ATemplate: string; const AValue: T): string; overload; static;
    class function Eval(AContext: IVelocityContext; const ATemplate: string): string; overload; static;
    class function Eval(AContext: IVelocityContext; ATemplate: IVelocityTemplate): string; overload; static;

    // PARSING

    // string operations
    class function Parse(const AString: string): IVelocityTemplate; overload; static;
    class function Parse(AContext: IVelocityContext; const AString: string): IVelocityTemplate; overload; static;

    // stream operations
    class function Parse(const AStream: TStream): IVelocityTemplate; overload; static;
    class function Parse(AContext: IVelocityContext; const AStream: TStream): IVelocityTemplate; overload; static;

    // file operations
    class function ParseFile(const AFile: string): IVelocityTemplate; overload; static;
    class function ParseFile(AContext: IVelocityContext; const AFile: string): IVelocityTemplate; overload; static;

  end;

  TEncodingHelper = class helper for TEncoding
    class function GetUTF8WithoutBOM: TEncoding; static;
    class property UTF8WithoutBOM: TEncoding read GetUTF8WithoutBOM;
  end;

implementation

uses
  Sempare.Boot.Template.Velocity.Evaluate,
  Sempare.Boot.Template.Velocity.PrettyPrint;

type
  TEmpty = TObject;

var
  GEmpty: TEmpty;

  { Velocity }

class function Velocity.Context(AOptions: TVelocityEvaluationOptions): IVelocityContext;
begin
  result := Sempare.Boot.Template.Velocity.Context.CreateVelocityContext(AOptions);
end;

class procedure Velocity.Eval<T>(ATemplate: IVelocityTemplate; const AValue: T; const AStream: TStream; const AOptions: TVelocityEvaluationOptions);
begin
  Eval(Context(AOptions), ATemplate, AValue, AStream);
end;

class procedure Velocity.Eval<T>(AContext: IVelocityContext; ATemplate: IVelocityTemplate; const AValue: T; const AStream: TStream);
var
  v: TVelocityValue;
begin
  v := TVelocityValue.From<T>(AValue);
  if typeinfo(T) = typeinfo(TVelocityValue) then
    v := v.AsType<TVelocityValue>();
  AcceptVisitor(ATemplate, TEvaluationVelocityVisitor.Create(AContext, v, AStream) as IVelocityVisitor);
end;

class procedure Velocity.Eval(ATemplate: IVelocityTemplate; const AStream: TStream; const AOptions: TVelocityEvaluationOptions);
begin
  Eval(ATemplate, GEmpty, AStream, AOptions);
end;

class procedure Velocity.Eval(const ATemplate: string; const AStream: TStream; const AOptions: TVelocityEvaluationOptions);
begin
  Eval(ATemplate, GEmpty, AStream, AOptions);
end;

class procedure Velocity.Eval<T>(const ATemplate: string; const AValue: T; const AStream: TStream; const AOptions: TVelocityEvaluationOptions);
begin
  Eval(Velocity.Parse(ATemplate), AValue, AStream, AOptions);
end;

class function Velocity.Parse(const AStream: TStream): IVelocityTemplate;
begin
  result := Parser.Parse(AStream);
end;

class function Velocity.Parser(AContext: IVelocityContext): IVelocityParser;
begin
  result := CreateVelocityParser(AContext);
end;

class function Velocity.Parse(const AString: string): IVelocityTemplate;
begin
  result := Parse(Context(), AString);
end;

class function Velocity.Parser: IVelocityParser;
begin
  result := CreateVelocityParser(Context);
end;

class function Velocity.PrettyPrint(ATemplate: IVelocityTemplate): string;
var
  v: TPrettyPrintVelocityVisitor;
begin
  v := TPrettyPrintVelocityVisitor.Create();
  try
    AcceptVisitor(ATemplate, v);
    result := v.ToString;
  finally
    v.Free;
  end;
end;

class procedure Velocity.Eval(AContext: IVelocityContext; const ATemplate: string; const AStream: TStream);
begin
  Eval(AContext, Velocity.Parse(AContext, ATemplate), GEmpty, AStream);
end;

class procedure Velocity.Eval<T>(AContext: IVelocityContext; const ATemplate: string; const AValue: T; const AStream: TStream);
begin
  Eval(AContext, Parse(ATemplate), AValue, AStream);
end;

class function Velocity.Parse(AContext: IVelocityContext; const AStream: TStream): IVelocityTemplate;
begin
  result := Parser(AContext).Parse(AStream);
end;

class function Velocity.ParseFile(AContext: IVelocityContext; const AFile: string): IVelocityTemplate;
type
{$IFDEF SUPPORT_BUFFERED_STREAM}
  TFStream = TBufferedFileStream;
{$ELSE}
  TFStream = TFileStream;
{$ENDIF}
var
  fs: TFStream;
begin
  fs := TFStream.Create(AFile, fmOpenRead);
  try
    result := Parse(AContext, fs);
  finally
    fs.Free;
  end;
end;

class function Velocity.ParseFile(const AFile: string): IVelocityTemplate;
begin
  result := ParseFile(Context, AFile);
end;

class function Velocity.Parse(AContext: IVelocityContext; const AString: string): IVelocityTemplate;
begin
  result := Parser(AContext).Parse(TStringStream.Create(AString, AContext.Encoding, false), true);
end;

class function Velocity.Eval(const ATemplate: string; const AOptions: TVelocityEvaluationOptions): string;
begin
  result := Eval(Context(AOptions), ATemplate);
end;

class function Velocity.Eval(ATemplate: IVelocityTemplate; const AOptions: TVelocityEvaluationOptions): string;
begin
  result := Eval(Context(AOptions), ATemplate);
end;

class function Velocity.Eval(AContext: IVelocityContext; const ATemplate: string): string;
begin
  result := Eval(AContext, Velocity.Parse(AContext, ATemplate));
end;

class function Velocity.Eval<T>(ATemplate: IVelocityTemplate; const AValue: T; const AOptions: TVelocityEvaluationOptions): string;
begin
  result := Eval(Context(AOptions), ATemplate, AValue);
end;

class function Velocity.Eval<T>(const ATemplate: string; const AValue: T; const AOptions: TVelocityEvaluationOptions): string;
begin
  result := Eval(Context(AOptions), ATemplate, AValue);
end;

class function Velocity.Eval<T>(AContext: IVelocityContext; ATemplate: IVelocityTemplate; const AValue: T): string;
var
  s: TStringStream;
begin
  s := TStringStream.Create('', AContext.Encoding, false);
  try
    Eval(AContext, ATemplate, AValue, s);
    result := s.DataString;
  finally
    s.Free;
  end;
end;

class function Velocity.Eval<T>(AContext: IVelocityContext; const ATemplate: string; const AValue: T): string;
begin
  result := Eval(AContext, Velocity.Parse(AContext, ATemplate), AValue);
end;

class function Velocity.Eval(AContext: IVelocityContext; ATemplate: IVelocityTemplate): string;
begin
  result := Eval(AContext, ATemplate, GEmpty);
end;

class procedure Velocity.Eval(AContext: IVelocityContext; ATemplate: IVelocityTemplate; const AStream: TStream);
begin
  Eval(AContext, ATemplate, GEmpty, AStream);
end;

{ TEncodingHelper }

class function TEncodingHelper.GetUTF8WithoutBOM: TEncoding;
begin
  result := UTF8WithoutPreambleEncoding;
end;

initialization

GEmpty := TObject.Create;

finalization

GEmpty.Free;

end.

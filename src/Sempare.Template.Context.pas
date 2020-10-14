(*%*********************************************************************************
 *                 ___                                                             *
 *                / __|  ___   _ __    _ __   __ _   _ _   ___                     *
 *                \__ \ / -_) | '  \  | '_ \ / _` | | '_| / -_)                    *
 *                |___/ \___| |_|_|_| | .__/ \__,_| |_|   \___|                    *
 *                                    |_|                                          *
 ***********************************************************************************
 *                                                                                 *
 *                        Sempare Templating Engine                                *
 *                                                                                 *
 *                                                                                 *
 *               https://github.com/sempare/sempare.template                       *
 ***********************************************************************************
 *                                                                                 *
 * Copyright (c) 2020 Sempare Limited,                                             *
 *                    Conrad Vermeulen <conrad.vermeulen@gmail.com>                *
 *                                                                                 *
 * Contact: info@sempare.ltd                                                       *
 *                                                                                 *
 * Licensed under the GPL Version 3.0 or the Sempare Commercial License            *
 * You may not use this file except in compliance with one of these Licenses.      *
 * You may obtain a copy of the Licenses at                                        *
 *                                                                                 *
 * https://www.gnu.org/licenses/gpl-3.0.en.html                                    *
 * https://github.com/sempare/sempare.template/docs/commercial.license.md          *
 *                                                                                 *
 * Unless required by applicable law or agreed to in writing, software             *
 * distributed under the Licenses is distributed on an "AS IS" BASIS,              *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.        *
 * See the License for the specific language governing permissions and             *
 * limitations under the License.                                                  *
 *                                                                                 *
 ********************************************************************************%*)
unit Sempare.Template.Context;

interface

{$I 'Sempare.Template.Compiler.inc'}

uses
  System.Rtti,
  System.SysUtils,
  System.Generics.Collections,
  Sempare.Template.AST,
  Sempare.Template.StackFrame,
  Sempare.Template.Common;

type
  ITemplateFunctions = interface
    ['{D80C777C-086E-4680-A97B-92B8FA08C995}']

    function GetIsEmpty: boolean;
    procedure AddFunctions(const AClass: TClass);
    procedure RegisterDefaults;
    function TryGetValue(const AName: string; out AMethod: TArray<TRttiMethod>): boolean;
    function Add(const AMethod: TRttiMethod): boolean;
    property IsEmpty: boolean read GetIsEmpty;
  end;

  TTemplateEvaluationOption = ( //
    eoNoPosition, //
    eoEvalEarly, //
    eoEvalVarsEarly, //
    eoStripRecurringNewlines, //
    eoTrimLines, //
    eoReplaceNewline, //
    // eoDebug, // TODO
    eoPrettyPrint, //
    eoStripRecurringSpaces, //
    eoConvertTabsToSpaces, //
    eoNoDefaultFunctions, //
    eoRaiseErrorWhenVariableNotFound //
    );

  TTemplateEvaluationOptions = set of TTemplateEvaluationOption;

  ITemplateContext = interface;

  TTemplateResolver = reference to function(AContext: ITemplateContext; const AName: string): ITemplate;

  ITemplateContext = interface
    ['{979D955C-B4BD-46BB-9430-1E74CBB999D4}']

    function TryGetTemplate(const AName: string; out ATemplate: ITemplate): boolean;
    function GetTemplate(const AName: string): ITemplate;
    procedure SetTemplate(const AName: string; ATemplate: ITemplate);

    function GetTemplateResolver: TTemplateResolver;
    procedure SetTemplateResolver(const AResolver: TTemplateResolver);

    function TryGetVariable(const AName: string; out AValue: TValue): boolean;
    function GetVariable(const AName: string): TValue;
    procedure SetVariable(const AName: string; const AValue: TValue);

    function GetOptions: TTemplateEvaluationOptions;
    procedure SetOptions(const AOptions: TTemplateEvaluationOptions);

    function GetScriptStartToken: string;
    procedure SetScriptStartToken(const AToken: string);
    function GetScriptEndToken: string;
    procedure SetScriptEndToken(const AToken: string);

    function TryGetFunction(const AName: string; out AFunction: TArray<TRttiMethod>): boolean;
    procedure SetFunctions(AFunctions: ITemplateFunctions);
    function GetFunctions(): ITemplateFunctions; overload;

    function GetMaxRunTimeMs: integer;
    procedure SetMaxRunTimeMs(const ATimeMS: integer);

    function GetEncoding: TEncoding;
    procedure SetEncoding(const AEncoding: TEncoding);

{$IFDEF SUPPORT_NET_ENCODING}
    procedure UseHtmlVariableEncoder;
{$ENDIF}
    function GetVariableEncoder: TTemplateEncodeFunction;
    procedure SetVariableEncoder(const AEncoder: TTemplateEncodeFunction);
    function GetVariables: ITemplateVariables;

    function GetNewLine: string;
    procedure SetNewLine(const ANewLine: string);

    property Functions: ITemplateFunctions read GetFunctions write SetFunctions;
    property NewLine: string read GetNewLine write SetNewLine;
    property TemplateResolver: TTemplateResolver read GetTemplateResolver write SetTemplateResolver;
    property MaxRunTimeMs: integer read GetMaxRunTimeMs write SetMaxRunTimeMs;
    property VariableEncoder: TTemplateEncodeFunction read GetVariableEncoder write SetVariableEncoder;
    property Variable[const AKey: string]: TValue read GetVariable write SetVariable; default;
    property Variables: ITemplateVariables read GetVariables;
    property Encoding: TEncoding read GetEncoding write SetEncoding;
    property Template[const AName: string]: ITemplate read GetTemplate write SetTemplate;
    property Options: TTemplateEvaluationOptions read GetOptions write SetOptions;
    property StartToken: string read GetScriptStartToken write SetScriptStartToken;
    property EndToken: string read GetScriptEndToken write SetScriptEndToken;
  end;

  ITemplateContextForScope = interface
    ['{65466282-2814-42EF-935E-DC45F7B8A3A9}']
    procedure ApplyTo(const AScope: TStackFrame);
  end;

function CreateTemplateContext(const AOptions: TTemplateEvaluationOptions = []): ITemplateContext;

var
  GDefaultRuntimeMS: integer = 60000;
  GDefaultOpenTag: string = '<%';
  GDefaultCloseTag: string = '%>';
  GNewLine: string = #13#10;
  GDefaultEncoding: TEncoding;

type
  TUTF8WithoutPreambleEncoding = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

var
  UTF8WithoutPreambleEncoding: TUTF8WithoutPreambleEncoding;

implementation

uses
{$IFDEF SUPPORT_NET_ENCODING}
  System.NetEncoding,
{$ENDIF}
  System.SyncObjs,
  Sempare.Template,
  Sempare.Template.Functions;

type

  TTemplateContext = class(TInterfacedObject, ITemplateContext, ITemplateContextForScope)
  private
    FTemplateResolver: TTemplateResolver;
    FTemplates: TDictionary<string, ITemplate>;
    FVariables: ITemplateVariables;
    FOptions: TTemplateEvaluationOptions;
    FStartToken: string;
    FEndToken: string;
    FEncoding: TEncoding;
    FFunctions: ITemplateFunctions;
    FFunctionsSet: boolean;
    FVariableEncoder: TTemplateEncodeFunction;
    FMaxRuntimeMs: integer;
    FLock: TCriticalSection;
    FNewLine: string;
  public
    constructor Create(const AOptions: TTemplateEvaluationOptions);
    destructor Destroy; override;

    function GetEncoding: TEncoding;
    procedure SetEncoding(const AEncoding: TEncoding);

    function TryGetTemplate(const AName: string; out ATemplate: ITemplate): boolean;
    function GetTemplate(const AName: string): ITemplate;
    procedure SetTemplate(const AName: string; ATemplate: ITemplate);

    function GetTemplateResolver: TTemplateResolver;
    procedure SetTemplateResolver(const AResolver: TTemplateResolver);

    function TryGetVariable(const AName: string; out AValue: TValue): boolean;
    function GetVariable(const AName: string): TValue;
    procedure SetVariable(const AName: string; const AValue: TValue);
    function GetVariables: ITemplateVariables;

    function GetOptions: TTemplateEvaluationOptions;
    procedure SetOptions(const AOptions: TTemplateEvaluationOptions);

    function GetScriptStartToken: string;
    procedure SetScriptStartToken(const AToken: string);
    function GetScriptEndToken: string;
    procedure SetScriptEndToken(const AToken: string);

    function GetMaxRunTimeMs: integer;
    procedure SetMaxRunTimeMs(const ATimeMS: integer);

{$IFDEF SUPPORT_NET_ENCODING}
    procedure UseHtmlVariableEncoder;
{$ENDIF}
    function GetVariableEncoder: TTemplateEncodeFunction;
    procedure SetVariableEncoder(const AEncoder: TTemplateEncodeFunction);

    function TryGetFunction(const AName: string; out AFunction: TArray<TRttiMethod>): boolean;
    procedure SetFunctions(AFunctions: ITemplateFunctions);
    function GetFunctions(): ITemplateFunctions; overload;

    function GetNewLine: string;
    procedure SetNewLine(const ANewLine: string);

    procedure ApplyTo(const AScope: TStackFrame);
  end;

function CreateTemplateContext(const AOptions: TTemplateEvaluationOptions): ITemplateContext;
begin
  result := TTemplateContext.Create(AOptions);
end;

{ TTemplateContext }

procedure TTemplateContext.SetTemplate(const AName: string; ATemplate: ITemplate);
begin
  FLock.Enter;
  try
    FTemplates.AddOrSetValue(AName, ATemplate);
  finally
    FLock.Leave;
  end;
end;

procedure TTemplateContext.ApplyTo(const AScope: TStackFrame);
var
  p: TPair<string, TValue>;
begin
  for p in FVariables do
  begin
    AScope[p.Key] := p.Value;
  end;
end;

constructor TTemplateContext.Create(const AOptions: TTemplateEvaluationOptions);
begin
  FOptions := AOptions;
  FMaxRuntimeMs := GDefaultRuntimeMS;
  SetEncoding(GDefaultEncoding);
  FStartToken := GDefaultOpenTag;
  FEndToken := GDefaultCloseTag;
  FTemplates := TDictionary<string, ITemplate>.Create;
  FVariables := TTemplateVariables.Create;
  FFunctions := GFunctions;
  FLock := TCriticalSection.Create;
  FNewLine := GNewLine;
end;

destructor TTemplateContext.Destroy;
begin
  FTemplates.Free;
  FVariables := nil;
  FFunctions := nil;
  FLock.Free;
  inherited;
end;

function TTemplateContext.TryGetFunction(const AName: string; out AFunction: TArray<TRttiMethod>): boolean;
begin
  FLock.Enter;
  try
    if not FFunctionsSet and not(eoNoDefaultFunctions in FOptions) then
    begin
      if FFunctions.IsEmpty then
        FFunctions.RegisterDefaults;
      FFunctionsSet := true;
    end;
    result := FFunctions.TryGetValue(AName.ToLower, AFunction);
  finally
    FLock.Leave;
  end;
end;

function TTemplateContext.GetEncoding: TEncoding;
begin
  result := FEncoding;
end;

function TTemplateContext.GetFunctions: ITemplateFunctions;
begin
  result := FFunctions;
end;

function TTemplateContext.GetMaxRunTimeMs: integer;
begin
  result := FMaxRuntimeMs;
end;

function TTemplateContext.GetNewLine: string;
begin
  result := FNewLine;
end;

function TTemplateContext.GetOptions: TTemplateEvaluationOptions;
begin
  result := FOptions;
end;

function TTemplateContext.GetVariable(const AName: string): TValue;
begin
  FLock.Enter;
  try
    result := FVariables[AName];
  finally
    FLock.Leave;
  end;
end;

function TTemplateContext.GetVariableEncoder: TTemplateEncodeFunction;
begin
  result := FVariableEncoder;
end;

function TTemplateContext.GetVariables: ITemplateVariables;
begin
  result := FVariables;
end;

function TTemplateContext.GetScriptEndToken: string;
begin
  result := FEndToken;
end;

function TTemplateContext.GetScriptStartToken: string;
begin
  result := FStartToken;
end;

function TTemplateContext.GetTemplate(const AName: string): ITemplate;
begin
  if not TryGetTemplate(AName, result) then
    result := nil;
end;

function TTemplateContext.GetTemplateResolver: TTemplateResolver;
begin
  result := FTemplateResolver;
end;

procedure TTemplateContext.SetEncoding(const AEncoding: TEncoding);
begin
  FEncoding := AEncoding;
end;

procedure TTemplateContext.SetFunctions(AFunctions: ITemplateFunctions);
begin
  FFunctions := AFunctions;
  FFunctionsSet := true;
end;

procedure TTemplateContext.SetMaxRunTimeMs(const ATimeMS: integer);
begin
  FMaxRuntimeMs := ATimeMS;
end;

procedure TTemplateContext.SetNewLine(const ANewLine: string);
begin
  FNewLine := ANewLine;
end;

procedure TTemplateContext.SetOptions(const AOptions: TTemplateEvaluationOptions);
begin
  FOptions := AOptions;
end;

procedure TTemplateContext.SetVariable(const AName: string; const AValue: TValue);
begin
  FLock.Enter;
  try
    FVariables[AName] := AValue;
  finally
    FLock.Leave;
  end;
end;

procedure TTemplateContext.SetVariableEncoder(const AEncoder: TTemplateEncodeFunction);
begin
  FVariableEncoder := AEncoder;
end;

procedure TTemplateContext.SetScriptEndToken(const AToken: string);
begin
  FEndToken := AToken;
end;

procedure TTemplateContext.SetScriptStartToken(const AToken: string);
begin
  FStartToken := AToken;
end;

procedure TTemplateContext.SetTemplateResolver(const AResolver: TTemplateResolver);
begin
  FTemplateResolver := AResolver;
end;

function TTemplateContext.TryGetTemplate(const AName: string; out ATemplate: ITemplate): boolean;
begin
  FLock.Enter;
  try
    result := FTemplates.TryGetValue(AName, ATemplate);
    if result then
      exit(true);
    if not Assigned(FTemplateResolver) then
      exit(false);
    ATemplate := FTemplateResolver(self, AName);
    if ATemplate = nil then
      exit(false);
    SetTemplate(AName, ATemplate);
    exit(true);
  finally
    FLock.Leave;
  end;
end;

function TTemplateContext.TryGetVariable(const AName: string; out AValue: TValue): boolean;
begin
  FLock.Enter;
  try
    result := FVariables.TryGetItem(AName, AValue);
  finally
    FLock.Leave;
  end;
end;

{$IFDEF SUPPORT_NET_ENCODING}

function HtmlEncode(const AString: string): string;
begin
  result := TNetEncoding.HTML.Encode(AString);
end;

procedure TTemplateContext.UseHtmlVariableEncoder;
begin
  FVariableEncoder := HtmlEncode;
end;

{$ENDIF}
{ TUTF8WithoutPreambleEncoding }

function TUTF8WithoutPreambleEncoding.GetPreamble: TBytes;
begin
  setlength(result, 0);
end;

{ TNoEncoding }

initialization

// setup our global
UTF8WithoutPreambleEncoding := TUTF8WithoutPreambleEncoding.Create;

GDefaultEncoding := TEncoding.UTF8WithoutBOM;

finalization

UTF8WithoutPreambleEncoding.Free;

end.

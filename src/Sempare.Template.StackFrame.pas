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
unit Sempare.Template.StackFrame;

interface

uses
  System.Generics.Collections,
  System.Rtti;

type
  TStackFrame = class
  private
    FParent: TStackFrame;
    FVariables: TDictionary<string, TValue>;

    function FindStackFrame(const AKey: string): TStackFrame;
    function GetItem(const AKey: string): TValue;

    procedure SetItem(const AKey: string; const Value: TValue);
  public
    constructor Create(const AParent: TStackFrame = nil); overload;
    constructor Create(const ARecord: TValue; const AParent: TStackFrame = nil); overload;
    destructor Destroy; override;
    function Clone(): TStackFrame;
    function Root: TValue;
    property Item[const AKey: string]: TValue read GetItem write SetItem; default;
  end;

implementation

uses
  System.SysUtils;

{ TStackFrame }

function TStackFrame.Clone: TStackFrame;
begin
  result := TStackFrame.Create(self);
end;

constructor TStackFrame.Create(const AParent: TStackFrame);
begin
  FParent := AParent;
  FVariables := TDictionary<string, TValue>.Create;
end;

constructor TStackFrame.Create(const ARecord: TValue; const AParent: TStackFrame);
begin
  Create(AParent);
  FVariables.Add('_', ARecord);
end;

destructor TStackFrame.Destroy;
begin
  FreeAndNil(FVariables);
  FParent := nil;
  inherited;
end;

function TStackFrame.FindStackFrame(const AKey: string): TStackFrame;
begin
  result := self;
  while not result.FVariables.ContainsKey(AKey) do
  begin
    result := result.FParent;
    if result = nil then
      exit;
  end;
end;

function TStackFrame.GetItem(const AKey: string): TValue;
var
  l: string;
  StackFrame: TStackFrame;
begin
  l := AKey.ToLower;
  StackFrame := FindStackFrame(l);
  if (StackFrame <> nil) then
    StackFrame.FVariables.TryGetValue(l, result);
end;

function TStackFrame.Root: TValue;
begin
  result := GetItem('_');
end;

procedure TStackFrame.SetItem(const AKey: string; const Value: TValue);

var
  l: string;
  StackFrame: TStackFrame;
begin
  l := AKey.ToLower;
  StackFrame := FindStackFrame(l);
  if StackFrame <> nil then
    StackFrame.FVariables.AddOrSetValue(l, Value)
  else
    FVariables.AddOrSetValue(l, Value);
end;

end.

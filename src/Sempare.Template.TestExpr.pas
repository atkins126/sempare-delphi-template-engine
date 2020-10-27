 (*%*************************************************************************************************
 *                 ___                                                                              *
 *                / __|  ___   _ __    _ __   __ _   _ _   ___                                      *
 *                \__ \ / -_) | '  \  | '_ \ / _` | | '_| / -_)                                     *
 *                |___/ \___| |_|_|_| | .__/ \__,_| |_|   \___|                                     *
 *                                    |_|                                                           *
 ****************************************************************************************************
 *                                                                                                  *
 *                        Sempare Templating Engine                                                 *
 *                                                                                                  *
 *                                                                                                  *
 *         https://github.com/sempare/sempare-delphi-template-engine                                *
 ****************************************************************************************************
 *                                                                                                  *
 * Copyright (c) 2020 Sempare Limited                                                               *
 *                                                                                                  *
 * Contact: info@sempare.ltd                                                                        *
 *                                                                                                  *
 * Licensed under the GPL Version 3.0 or the Sempare Commercial License                             *
 * You may not use this file except in compliance with one of these Licenses.                       *
 * You may obtain a copy of the Licenses at                                                         *
 *                                                                                                  *
 * https://www.gnu.org/licenses/gpl-3.0.en.html                                                     *
 * https://github.com/sempare/sempare-delphi-template-engine/blob/master/docs/commercial.license.md *
 *                                                                                                  *
 * Unless required by applicable law or agreed to in writing, software                              *
 * distributed under the Licenses is distributed on an "AS IS" BASIS,                               *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.                         *
 * See the License for the specific language governing permissions and                              *
 * limitations under the License.                                                                   *
 *                                                                                                  *
 *************************************************************************************************%*)
unit Sempare.Template.TestExpr;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TTestTemplateExpr = class
  public
    [Test]
    procedure TestExprBool;
    [Test]
    procedure TestExprNum;
    [Test]
    procedure TestExprNumDiv;
    [Test]
    procedure TestExprNumFloat;
    [Test]
    procedure TestExprStr;
    [Test]
    procedure TestSimpleVariable;
    [Test]
    procedure TestTernary;
    [Test]
    procedure TestInExpr;

  end;

implementation

uses
  Sempare.Template;

procedure TTestTemplateExpr.TestSimpleVariable;
begin
  Template.parse('before <% abc %> after');
end;

procedure TTestTemplateExpr.TestTernary;
begin
  Assert.AreEqual('a', Template.Eval('<% true?''a'':''b'' %>'));
  Assert.AreEqual('b', Template.Eval('<% false?''a'':''b'' %>'));
end;

procedure TTestTemplateExpr.TestExprNum;
begin
  Template.parse('before <% a := 123 %> after ');
end;

procedure TTestTemplateExpr.TestExprNumDiv;
begin
  Assert.AreEqual('2', Template.Eval('<% 4.7 div 2 %>'));
  Assert.AreEqual('2', Template.Eval('<% 4 div 2 %>'));
  Assert.AreEqual('2.5', Template.Eval('<% 5 / 2 %>'));
end;

procedure TTestTemplateExpr.TestExprNumFloat;
begin
  Template.parse('before <% a := 123.45 %> after ');
end;

procedure TTestTemplateExpr.TestExprStr;
begin
  Template.parse('before <% a := ''hello world'' %> after ');
end;

procedure TTestTemplateExpr.TestInExpr;
begin
  Assert.AreEqual('false', Template.Eval('<% 0 in [1,2,3] %>'));
  Assert.AreEqual('true', Template.Eval('<% 1 in [1,2,3] %>'));
  Assert.AreEqual('true', Template.Eval('<% 2 in [1,2,3] %>'));
  Assert.AreEqual('true', Template.Eval('<% 3 in [1,2,3] %>'));
  Assert.AreEqual('false', Template.Eval('<% 4 in [1,2,3] %>'));
  Assert.AreEqual('true', Template.Eval('<% ''hello world'' in [1,''hello world'',3] %>'));
  Assert.AreEqual('false', Template.Eval('<% ''hello'' in [1,''hello world'',3] %>'));
end;

procedure TTestTemplateExpr.TestExprBool;
begin
  Template.parse('before <% a := true %> after ');
  Template.parse('before <% a:= false %> after ');
  Template.parse('before <% a:= true and false %> after ');
  Template.parse('before <% a:= true or false %> after ');
  Template.parse('before <% a:= true and false or true %> after ');
end;

initialization

TDUnitX.RegisterTestFixture(TTestTemplateExpr);

end.

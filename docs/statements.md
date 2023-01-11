# ![](../images/sempare-logo-45px.png) Sempare Template Engine

Copyright (c) 2019-2023 [Sempare Limited](http://www.sempare.ltd)

## Statements

1. [print](#print)
2. [assignment](#assignment)
3. [if](#if)
4. [for](#for)
5. [while](#while)
6. [include](#include)
7. [with](#with)
8. [template](#template)
9. [require](#require)
10. [ignorenl](#ignorenl)
11. [cycle](#cycle)

### print

Within a script, all text outside of the script _'<%'_ start and _'%>'_ end tokens is output.

```
hello world
```

This outputs _'hello world'_ as expected.

```
<% stmt := 'is a' %>
This <% stmt %> test.
```
The above example results in _'this is a test.'_ being output.

### assignment
Within a script block, you can create temporary variables for use within the template. Basic types such a string, boolean and numbers can be used.
```
<% num := 123 %>
<% str := 'abc' %>
<% bool := false %>
```
### if

You may want to conditionally include content:
```
Some text
<% if condition %>
some conditional text
<% end %>
Some more text
```
In the above scenario, you can conditionally include some text by referencing the _condition_. This could be a variable or a complex expression. If the condition expression is a non boolean value, such as a string or a number, the expression evaluates to true for a non empty string and a non zero number.

More complicated condition blocks can be created using _elif_ and _else_ statements.
```
some text
<% if condition %>
    block 1
<% elif condition2 %>
    block 2
<% elif condition3 %>
    block 3
<% else %>
    last block
<% end %>
    the end
```

### for

The _for to/downto_ loop comes in two forms as it does in Object Pascal:
```
increasing integers from 1 to 10
<% for i := 1 to 10 %>
    number <% i %>
<% end %>

decreasing integers from 10 down to 1
<% for i := 10 downto 1 %>
    number <% i %>
<% end %>
```

**NOTE** Loop variables can be updated within the scope of the block without the loop integrity being compromised. 

You can change the _step_ interval as follows:
```
<% for i := 1 to 10 step 2 %>
    number <% i %>
<% end %>
```

The other _for in_ variation is as follows:
```
Attendees:
<%for i in _ %> 
   <% i.name %> <% i.age %>
<%end%> 
```

You may also use _offset_ and _limit_ on _for in_ statements:
```
Attendees:
<%for i in _ offset 20 limit 10 %> 
   <% i.name %> <% i.age %>
<%end%> 
```

Further, there are _onbegin_, _onend_, _betweenitems_ and _onempty_ events that can be used.
```
Attendees:
<%for i in _ %> 
		<li><% i.name %> <% i.age %></li>
   <% onbegin %>
		<ul>
   <% onend %>
		</ul>
   <% onempty %>
		<i>There are no entries</i>   
<%end%>
```

With the following Delphi:
```
type
  TInfo = record
    Name: string;
    age: integer;
    constructor create(const n: string; const a: integer);
  end;
var
  info: TList<TInfo>;
begin
  info := TList<TInfo>.create;
  info.AddRange([TInfo.create('conrad', 10), TInfo.create('christa', 20)]);
  writeln(Template.Eval(template, info));
  info.Free;
end;
```

The above produces the output:
```
Attendees:
   conrad 10
   christa 20
```

### while

While blocks are very flexibe looping constructs based on a boolean condition being true.

```
<% i := 1 %>
<% while i <= 3 %>
   <% i %>
   <% i := i + 1%>
<% end %>
```

This produces the following:
```
   1
   2
   3
```
**NOTE** you must ensure the terminating condition is eventually true so that the template can be rendered.

While loops may also have _offset_ and _limits_ defined:

```
<% i := 1 %>
<% while i <= 10 offset 5 limit 5 %>
   <% i %>
   <% i := i + 1%>
<% end %>
```
While loops may also have _onbegin_, _onend_, _betweenitems_ and _onempty_ events defined:
```
<% i := 1 %>
<% while i <= 10 offset 5 limit 5 %>
			<% i %>
			<% i := i + 1%>
		<% onbegin %>
			<ul>
		<% onend %>
			</ul>
		<% onempty %>
			<i>no values</i>
<% end %>
```

## break / continue

The _for_ and _while_ loops can include the following _break_ and _continue_ statements to assist with flow control.

An example using _continue_:
```
<% for i := 0 to 10 %>
 <% if i mod 2 = 1 %><% continue %><% end %><% i %>
<% end %>
```

This will produce:
```
0 2 4 6 8 10 
```

An example using _break_:
```
<% i := 0 %>
<% while true %>
 <% if i = 3%><% break %><% end %><% i %><% i:=i+1%>
<% end %>
```
This will produce
```
0 1 2
```

### include

You may want to decompose templates into reusable parts. You register templates on a Template context. 

```
type
    TInfo = record
        year : integer;
        company : string;
        email : string;
    end;
begin
   var ctx := Template.context();
   ctx['year'] := 2019;
   ctx['company'] := 'Sempare Limited';
   ctx['email'] := 'info@sempare.ltd';
   ctx.RegisterTemplate('header', Template.Parse('Copyright (c) <% year %> <% company %> '));
   ctx.RegisterTemplate('footer', Template.Parse('Contact us <% email %> '));
   var tpl := Template.parse('<% include (''header'') %> some content <% include (''footer'') %>');
```

include() can also take a second parameter, allowing for improved scoping of variables, similar to the _with_ statement.

### with

The with() statement is used to localise variables from a nested structure.

To illustrate, the following
```
type
	TInfo = record
		level1 : record
			level2 : record
				value : string;
				level3 : record
					level4 : record
						value : string;
					end;
				end;
			end;
		end;
	end;
begin
	var info : TInfo;
	info.level1.level2.value := 'test';
	info.level1.level2.level3.level4.value := 'hello';	
	Template.Eval('<% level1.level2.level3.level4.value %> <% level1.level2.level3.level4.value %> <% level1.level2.level3.level4.value %>', info)

	// can be replaced with
	Template.Eval('<% with level1.level2.level3.level4 %><% value %> <% value %> <% value %><% end %>', info)

```

The _with()_ statement will push all fields/properties in a record/class into a new scope/stack frame. 

### template

Localised templates can also be defined locally within a template.

The _include_() statement is used to render a local template as is the normal behaviour. Note that local templates take precedence over templates defined in a context when they are being resolved.

Using the TInfo structure above it could be appli
```
<% template 'mytemplate' %>
	<% value %>
<% end %>
<% include ('mytemplate', level1.level2) %>	
<% include ('mytemplate', level1.level2.level3.level4) %>	
```

### require

The _require_() statement is used to validate that the input variable is of a particular type.

e.g.
```
type
	TInfo = record
		Name : string;
	end;
	
begin
	var info : TInfo;
	info.name := 'Jane';
	writeln(Template.Eval('<% require(''TInfo'') %>', info));
end;
```

An exeption is thrown when the

_require_ can take multiple parameters - in which case the input must match one of the types listed.

### ignorenl

The purpose of an _ignorenl_ block is to allow for template designers to space out content for easy maintenance, but to allow for the output to be more compact when required.

```

	<table>
<% ignorenl %>
		<tr>
			<td>Col1</td>
			<td>Col2</td>
		</tr>
<% end %>
	</table>

```

This would yield something like

```
  <table>
  	<tr><td>Col1</td><td>Col2</td></tr>
  </table>
```

The _eoAllowIgnoreNL_ must be provided in the Context.Options or via Template.Eval() options.

### cycle

This allows for values to cycle when rendering content. e.g. 

```
<% for person in people %>
          <tr class="<% cycle ('odd-row','even-row') %>">
              <td><% person.firstname %></td>
              <td><% person.lastname %></td>
          </tr>
    <% onbegin %>
        <table>
            <tr>
                <th>First Name</th>
                <th>Last Name</th>
            </tr>
    <% onend %>
        </table>
    <% onempty %>
       There are no entries
</% end%>
```

Given a 'people' structure:
```
type
    TPerson = class
    public:
        firstname:string;
        lastname: string;
        constructor Create(const AFirstName, ALastName:string);
    end;
    
var
    LPeople := TObjectList<TPerson>.Create;
    // ...
    LPeople.Add(TPerson.Create('Mary', 'Smith'));
    LPeople.Add(TPerson.Create('Peter', 'Pan'));
    LPeople.Add(TPerson.Create('Joe', 'Bloggs'));
    // ...
```

would yield something like:
```
	<table>
        <tr>
            <th>First Name</th>
            <th>Last Name</th>
        </tr>
        <tr class="odd-row">
            <td>Mary</td>
            <td>Smith</td>
        </tr>
        <tr class="even-row">
            <td>Peter</td>
            <td>Pan</td>
        </tr>
        <tr class="odd-row">
            <td>Joe</td>
            <td>Bloggs</td>
        </tr>
	</table>
```
## JSON RPC Framework for Delphi

Contents
---
* [Introduction](#introduction)
* [Creating an interface](#creating-an-interface)
* [Obtaining an ISomeJSONRPC interface](#obtaining-an-isomejsonrpc-interface)
* [Client or Server?](#client-or-server)
* [Making JSON RPC calls in the client](#making-json-rpc-calls-in-the-client)
* [JSON RPC server](#json-rpc-server)
* [Handling Exceptions](#handling-exceptions)
* [Events](#events)
* [Logging](#logging)
  * [Client side logging](#client-side-logging)
  * [Server side logging](#server-side-logging)
* [JSON RPC transport wrapper](#json-rpc-transport-wrapper)
* [Using the HTTP transport wrapper](#using-the-http-transport-wrapper)
* [Using the TCP transport wrapper](#using-the-tcp-transport-wrapper)
* [Handling large numbers](#handling-large-numbers)
* [Troubleshooting](#troubleshooting)
* [Extensibility](#extensibility)
* [Examples](#examples)
* [Bugs / Feature Requests](#bugs--feature-requests)

Introduction
---
This is a JSON RPC Framework for Delphi, implementing both the code for the
client and the server side, by Chee-Wee Chua.

On the client side, it is easy to use, and allows you to just design an
interface, obtain the interface from a function you designed (an expert/wizard
may appear in future), and call it.

The JSON RPC can run over HTTP(S), or TCP, or whatever extensible protocol there
may be, as long as you create a class that descends from TJSONRPCTransportWrapper.

Creating an interface
---
You create an interface that mirrors what the server offers.
In the example below, the interface is called ISomeJSONRPC.

```
ISomeJSONRPC = interface(IJSONRPCMethods)
  [YourGUIDhere] // it is important to declare a GUID, or the compiler will
  complain "E2015 Operator not applicable to this operand type"
    [JSONNotify]
    procedure ANotifyMethod;

    function AddSomeXY(X, Y: Integer): Integer;

    procedure SomeSafeCallException; safecall;
end;
```
No matter what your design is, your interface needs to descend from IJSONRPCMethods.

You'll also need to register the interface by calling InvRegistry.RegisterInterface
on your interface, like so:

InvRegistry.RegisterInterface(ISomeJSONRPC)

It is recommended that you call RegisterInterface in the initialization, so
that if you implement the server at the same time, the interface is registered
on the server side as well.

Obtaining an ISomeJSONRPC interface
---
Create a function that returns an ISomeJSONRPC interface.

The most simple function to return an ISomeJSONRPC interface is as follows:
```
function GetSomeJSONRPC(const ServerURL: string): ISomeJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(ISomeJSONRPC));
  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);
  LJSONRPCWrapper.ServerURL := ServerURL;
  
  // declare a GUID on your interface, or the compiler will complain "E2015
  Operator not applicable to this operand type" on the line below.
  Result := LJSONRPCWrapper as ISomeJSONRPC; 
end;
```

Client or Server?
---
You can choose to only implement the client, while the server is implemented by
some other entity.

Alternatively, you can choose to implement only the server, handling calls from clients.

Making JSON RPC calls in the client
---

JSON RPC calls are dispatched to the server when you make any calls to a
variable of the type ISomeJSONRPC.

When you call ANotifyMethod, it's executed on the server, and doesn't return
any results, since it's a procedure.

When you call AddSomeXY, specifying X and Y, it returns an integer after
getting executed on the server side.

If your return result is based on the TJSONValue type, then it is automatically freed.
If it is a native type such as a record or a string (classes not supported),
then it is automatically managed by the Delphi RTL.

JSON RPC server
---
Create the server by descending it from the TInvokableClass, and include your
interface with it.

```
  TSomeJSONRPC = class(TInvokableClass, ISomeJSONRPC)
  public
    constructor Create; override;
    destructor Destroy; override;

    { ISomeJSONRPC }
    procedure ANotifyMethod;
    function AddSomeXY(X: Integer; Y: Integer): Integer;
    procedure SomeSafeCallException; safecall;
  end;
```

You need to register the server class you've implemented by calling
*  InvRegistry.RegisterInvokableClass(TSomeJSONRPC);
*  RegisterJSONRPCWrapper(TypeInfo(ISomeJSONRPC));

Notification IDs are automatically returned, if you _do not_ include the
[JSONNotify] attribute on your method.

Handling Exceptions
---
When you call, for example, SomeSafeCallException, a method that may or may not
throw an exception during its execution, if you choose a central exception
handler, mark it with a safecall directive.

If you choose not to have a central exception handler, you need to wrap each
JSON RPC call with a try except handler.

To set up a central exception handler, use the AssignJSONRPCSafeCallExceptionHandler routine.

Events
---
Each stage of the JSON RPC process is marked with events.

#### Client side events
---
The JSON RPC wrapper has 3 events that you can assign your own routines to, in
order to monitor outgoing client requests, incoming server responses, and the
URL that requests are sent to (only if the final URL is different from the base URL).

* OnLogOutgoingJSONRequest
  * reference to procedure(const AJSONRPCRequest: string)
* OnLogIncomingJSONResponse
  * reference to procedure(const AJSONRPCResponse: string);
* OnLogServerURL
  * reference to procedure(const AServerURL: string);

#### Server side events
---
The JSON RPC server wrapper has 2 events that you can also assign your own
routines to, in order to monitor incoming client requests, and outgoing server responses.

* OnLogIncomingJSONRequest
  * reference to procedure(const AJSONRPCRequest: string);
* OnLogOutgoingJSONResponse
  * reference to procedure(const AJSONRPCResponse: string);
  

Logging
---
The JSON RPC framework supports logging outgoing request and incoming response
on the client side, as well as logging incoming request and outgoing response on the server side.

### Client side logging
---
To enable client side logging, assign handlers to OnLogOutgoingJSONRequest and
OnLogIncomingJSONResponse properties.

The handlers have the signature: procedure(const JSON: string);

```
  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);
  ... 

  LJSONRPCWrapper.OnLogOutgoingJSONRequest := AOnLoggingOutgoingJSONRequest;
  LJSONRPCWrapper.OnLogIncomingJSONResponse := AOnLoggingIncomingJSONResponse;
```

### Server side logging
---
To enable server side logging, assign handlers to OnLogIncomingJSONRequest and
OnLogOutgoingJSONResponse properties.

The handlers have the signature: procedure(const JSON: string);
```
var
  LServer: TJSONRPCServerRunner;
...
begin
  LServer := TJSONRPCServerIdHTTPRunner.Create; // Match the runner type with
  the client's
  ...
  LServer.OnLogIncomingJSONRequest := procedure (const AJSONRequest: string)
  begin
    WriteLn('Received JSON RPC: ', AJSONRequest);
  end;

  LServer.OnLogOutgoingJSONResponse := procedure (const AJSONResponse: string)
  begin
    WriteLn('Sent JSON RPC: ', AJSONResponse);
  end;
```

JSON RPC transport wrappers
---
There are 2 existing transport wrappers, and they are located in
JSONRPC.TransportWrapper.HTTP.pas and JSONRPC.TransportWrapper.TCP.pas.

Having a transport wrapper isolates the JSON RPC framework from dealing directly
with any transport protocol related code.

Design your transport wrapper class in a unit, and then in your initialization
code, assign your class to the global variable _GJSONRPCTransportWrapperClass_.

The transport wrapper needs to be used in both the client and the server.

### Using the HTTP transport wrapper
---
In order to use the HTTP transport wrapper, include the unit
JSONRPC.TransportWrapper.HTTP in your code.

### Using the TCP transport wrapper
---
In order to use the TCP transport wrapper, include the unit
JSONRPC.TransportWrapper.TCP in your code.

Handling large numbers
---
Delphi doesn't handle serializing large numbers well, as certain routines do
not transform numbers precise enough, ie, StrToFloat and FloatToStr routines, among others.

In addition, because the range of the MinValue and MaxValue definitions in
floating point numbers are not compatible between 32-bit and 64-bit Delphi,
handling floating point numbers are problematic.

As such, this JSON RPC framework handles large numbers by using Rudy Velthuis'
BigNumbers framework. You can either get it from GitHub's TurboPack repository,
or use RAD Studio's GetIt.

It is recommended that you choose to use BigDecimals and BigIntegers when
serializing numbers.

However, if you do not wish to follow the recommendations, you can still use
any of the native Delphi floating number types: Single, Double, Extended.

Troubleshooting
---
When implementing your JSON RPC interface, besides inheriting from IJSONRPCMethods,
you'll need to add a GUID to your interface, failure to do so will get you the
compile-time error "E2015 Operator not applicable to this operand type".

When implementing the server, you'll need to call RegisterInvokableClass on your
server class.

Extensibility
---
What if you want to handle custom data types on the server?

You can design a custom record data type, and then register it using
RegisterRecordHandler, without altering any part of the framework.

Examples
---

There are sample clients and servers in the examples directory.
The clients and servers have been separately tested to run on Android, Linux
and Windows.

Bugs / Feature Requests
---
If you find any bugs or have any feature requests, please file an issue on the
repository.



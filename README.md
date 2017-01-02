[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/wikiti/extension-networking.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/extension-networking)  [![CircleCI](https://circleci.com/gh/wikiti/extension-networking.svg?style=shield)](https://circleci.com/gh/wikiti/extension-networking)

# OpenFL Networking Library

![extension-networking logo](https://raw.githubusercontent.com/wikiti/extension-networking/master/dev/logo.png)


## Description

`extension-networking` is a library developed for [OpenFL](http://www.openfl.org/) to facilitate connections between applications, using *TCP* sockets, and following the scheme of event-driven programming.

The structure followed by this library is quite classic, following this diagram:

![](https://raw.githubusercontent.com/wikiti/extension-networking/master/dev/diagram.png)

Basically, a network can have multiple sessions. Each session will consist of one (intermediate) server and multiple clients. Just create some sessions, and some events, and you are ready to go!


## Installation

Add the library to your `project.xml`:

```xml
<haxelib name="extension-networking" />
```

And use `haxelib` to install it:

```shell
$ haxelib install extension-networking
```

## Considerations

Please, take in mind the following considerations before programming anything:

- Network events are processed on a queue after each OpenFL frame (`ENTER_FRAME` event).
- Currently, only TCP sockets are supported.
- Server mode is only available in native targets (*hxcpp* and *neko*).
- Messages are limited to a size of 65535 bytes (16-bit unsigned integer).
- HTML5 sockets connects via *WebSockets*.

## Usage

### Examples

There is a project example on the [examples](examples) folder. **FEAR NOT!** The [basic-example](examples/basic-example) has only one haxe file with a few lines of simple code.

If you don't want to download and execute code, then read the following section.

Examples list:

- [basic-example](examples/basic-example)
- [tic-tac-toe](examples/tic-tac-toe)

### Basic usage

First of all, a **server** is an application which allows multiple **clients** to connect to it.

This library is based on **sessions**, so you can handle multiple connections to multiple servers.

#### Registering sessions

To register a sessión as a server listening to the port `8888` to all interfaces, use:

```haxe
import networking.Network;
import networking.utils.NetworkMode;

// ...

var server = Network.registerSession(NetworkMode.SERVER, { ip: '0.0.0.0', port: 8888, max_connections: 4 });
server.start();
```

To create a client that connects to that server:

```haxe
import networking.Network;
import networking.utils.NetworkMode;

// ...

var server_ip = '127.0.0.1';
// You can also use host names:
// var server_ip = 'www.example.com';

var client = Network.registerSession(NetworkMode.CLIENT, { ip: server_ip, port: 8888 });
client.start();
```

You can check for the connection statuses.

#### Messages

Messages are serialized and send as dynamic objects. For example, to send a message from the client to the server:

```haxe
client.send({ message: 'Hello world!', verb: 'test' });
```

To notify all clients of the server:

```haxe
server.send({ message: 'Global message!', verb: 'test' });
```

To notify only the first client:

```haxe
server.clients[0].send({ message: 'Pst! This is a secret between you and me!', verb: 'test' })
```

Now, after that, it's time to add some events to handle messages. For example, to send information to a client after it has connected:

```haxe
server.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {
  var connected_client = event.client();
  connected_client.send({ message: 'Welcome to the server!', verb: 'test });
});
```

To process the data recieved by the server:

```haxe
client.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(event: NetworkEvent) {
  trace(event.data.message); // Hello world!
});
```

#### Disconnections

To disconnect a client from the server:

```haxe
// Disconnect the client right after it's connected.
server.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {
  server.disconnectClient(event.client);
});

// You can also type something like this:
server.disconnectClient(server.clients[0]);

// To disconnect all clients and keep the session:
for(client in server.clients) {
  server.disconnectClient(client);
}

```

To disconnect from a server:

```haxe
// Disconnect from the server right after it's connected.
client.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {
  client.disconnectClient();
  // or `Network.destroySession(client)` to destroy the session.
});
```

#### Clossing sessions

Finally, the sessions must be closed when required, for clients:

```haxe
Network.destroySession(client);
```

And for the server (which will disconnect all clients):

```haxe
Network.destroySession(server);
```

You'll probably don't want to reuse sessions; just create a new one if you need it, and destroy the old one.

More information about events on the [Events](#events) section.

#### Identifiers

Each session will have an unique identifier or `uuid`, which will help to identify each server or client. By default, it will have assigned a random value (string).

```haxe
// Server uuid
server.uuid;

// Server's client uuid
server.clients[0].uuid;
```

```haxe
// Client uuid
client.uuid;

// Client's server uuid
client.server.uuid;
```

If you want to use your own identifiers (for example, loading them from a file), see the *Parameters for sessions* section.

### Parameters for sessions

The following parameters are accepted for session registration. If a parameter hast a default value, then it can be omitted.

#### Server parameters

| Parameter name | Description | Type | Default value |
| -------------- | ----------- | ---- | ------------- |
| ip | Server ip (host) to bind. | String | 127.0.0.1 |
| port | Server TCP port to bind. | PortType (Int) | 9696 |
| max_connections | Max connections allowed at the same time. | Int | 24 |
| uuid | Unique identifier (server). | String | random uuid string |

Example:

```haxe
var server = Network.registerSession(NetworkMode.SERVER, {
  ip: '0.0.0.0',
  port: 7777,
  max_connections: 50,
  uuid: 'server_id'
});
```


#### Client parameters

| Parameter name | Description | Type | Default value |
| -------------- | ----------- | ---- | ------------- |
| ip | Server ip to connect into. | String | 127.0.0.1 |
| port | Server TCP port to connect into. | PortType (Int) | 9696 |
| uuid | Unique identifier (client). | String | random uuid string |

Example:

```haxe
var client = Network.registerSession(NetworkMode.CLIENT, {
  ip: '127.0.0.1',
  port: 7777,
  uuid: 'client_id'
});
```

### Events

As we stated before, this library is based on events. The following events are available in `networking.utils.NetworkEvent`:

| Event | Server | Client |
| ----- | -------------------- | -------------------- |
| INIT_SUCCESS | Server successfully binded to the given ip and port. | Client connected to the server successfully. |
| INIT_FAILURE | Server could not bind the given ip and port. | Client could not connect to the server. |
| CONNECTED | New client connected. | Client connected to the server (after INIT_SUCCESS). |
| DISCONNECTED | Client disconnected (due to an error or voluntarily). | Disconnected from the server (due to an error), which means that the socket is closed (asynchronously). May be fired after `CLOSED` event. |
| CLOSED | Session closed (called on `session.stop()` or `Network.destroySession(session)`). | Disconnected from the server (voluntarily) by closing the session (called on `session.stop()` or `Network.destroySession(session)`). |
| MESSAGE_RECEIVED | Message recieved from a client. | Message recieved from the server. |
| MESSAGE_SENT | Message sent to a client. | Message sent to the server. |
| MESSAGE_SENT_FAILED | An error ocurred while sending a message to a specific client. | An error ocurred while sending a message to the server. |
| MESSAGE_BROADCAST | Send message to all clients. | - |
| MESSAGE_BROADCAST_FAILED | Something went wrong while sending a broadcast message. | - |
| SERVER_FULL | A client tried to connect to the server, which is full. | The client tried to connect to a full server. |

### Message verbs

To group messages, you can use whatever syntax you like inside the message body. However, we recommend you using the `verb` strategy; just create a `verb` attribute, and assign a *meaning* to it to distinguish message types. For example:

```haxe
server.addEventListener(NetworkEvent.MESSAGE_RECIEVED, function(e: NetworkEvent) {
  switch(e.data.verb) {
    case 'send_message':
      trace(e.data.str);
    case 'give_me_a_puppy':
      event.client.send({ name: e.data.name, age: 2, breed: 'Dalmatian' });
  }
});
```

```haxe
client.send({ verb: 'send_message', str: 'Hello!' });
client.send({ verb: 'give_me_a_puppy', name: 'Cooper' });
```

Internally, the library uses a few message verbs to handle some cases:

```yml
_core:
  messages:
    auto_verb: "Flag to determine if the current message is a event-driven shortcut."
  sync:
    update_client_data: "Update client information. Required params: uuid(String)"
  errors:
    server_full: 'The server is full.'
```

Core message handling will prevent event propagation: you won't have to handle them manually.

#### Message verbs (events-driven shortcut)

You can also use the `trigger` and `on` method to automatically manage verbs, so you can separate them easily.

```haxe
server.trigger("say_hi", { to: "world" });
```

```haxe
client.on("say_hi", function(data: Dynamic) {
  trace('Hello, ${data.to}!');
});
```

Which is a pseudo-equivalent of:

```haxe
server.send({ verb: "say_hi", to: "world" });
```

```haxe
client.addEventListener(NetworkEvent.MESSAGE_RECIEVED, function(event: NetworkEvent) {
  if(event.verb == "say_hi") {
    trace('Hello, ${event.data.to}!');
  }
});
```

The first case is has more semantic meaning, which improves readability.

Note that clients can also *trigger events* into the server:

```haxe
client.trigger("respond", { date: Date.now() });
```

```haxe
server.on("respond", function(data: Dynamic) {
  trace('Hello, server! Today's ${data.date}');
});
```

If you need to check who the sender is, use an extra parameter called `event`, which will contain information about the network event.

```haxe
session.on("verb", function(data: Dynamic, event: NetworkEvent) {
  trace(event.data); // { verb: 'verb', value: 'test', etc: 'etc' }
  trace(event.sender); // { uuid: '...', active: true }
});
```

`event` argument is available for callbacks in both server and client mode.

For more complex situations, we encourage you to use raw event handling (with `addEventListeners`) instead of these quick shortcuts.

### Session handling

If you want (or need) to handle multiple connections at once, you can use as many sessions as you wish. For example, to handle 2 servers and a client at the same time:

```haxe
var server1 = Network.registerSession(NetworkMode.SERVER, { ip: '0.0.0.0', port: 8888, max_connections: 4 });
var server2 = Network.registerSession(NetworkMode.SERVER, { ip: '0.0.0.0', port: 8889, max_connections: 4 });
var client1 = Network.registerSession(NetworkMode.CLIENT, { ip: '89.73.42.3', port: 7777 });

server1.start();
server2.start();
client1.start();
```

The registered sessions will be available in `Network.sessions` list:

```haxe
trace(Network.sessions.length); // 3
```

### Logging

To show the network logs on the console (*stdout*), define the `network_logging` define; just add this to your `project.xml`:

```xml
<haxedef name="network_logging" />
```

To include *backtraces*, use `network_logging_with_backtrace` instead:

```xml
<haxedef name="network_logging_with_backtrace" />
```

## Development

Clone the repository:

```shell
$ git clone https://github.com/wikiti/extension-networking
```

Then, setup the development directory:

```shell
$ haxelib dev extension-networking extension-networking
```

To run tests use [munit](https://github.com/massiveinteractive/MassiveUnit):

```shell
$ haxelib run munit test
```

## TODO

- Add more unit tests related to sockets.

## Contributors

This project has been developed by:

| Avatar | Name | Nickname | Email |
| ------ | ---- | -------- | ----- |
| ![](http://www.gravatar.com/avatar/2ae6d81e0605177ba9e17b19f54e6b6c.jpg?s=64)  | Daniel Herzog | Wikiti | [info@danielherzog.es](mailto:info@danielherzog.es)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.md) [![Haxelib Version](https://img.shields.io/github/tag/wikiti/extension-networking.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/extension-networking)  [![CircleCI](https://circleci.com/gh/wikiti/extension-networking.svg?style=shield)](https://circleci.com/gh/wikiti/extension-networking)

# OpenFL Networking Library

![extension-networking logo](https://raw.githubusercontent.com/wikiti/extension-networking/master/dev/logo.png)


## Description

`extension-networking` is a library developed for [OpenFL](http://www.openfl.org/) to facilitate connections between applications, using *TCP* sockets, and following the scheme of event-driven programming.

## Installation

Add the library to your `project.xml`:

```xml
<haxelib name="extension-networking" />
```

And use `haxelib` to install it:

```shell
$ haxelib install extension-networking
```

## Usage

Please check the [wiki](https://github.com/wikiti/extension-networking/wiki) for more information about usage and configuration.


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

## Publish

Update the haxelib version on `haxelib.json` and commit the changes to `master`,
and push the changes:

```sh
# Update haxelib.json
git commit -m "Update version"
git push origin master
```

Create a git tag with the current version and push it:

```sh
git tag x.y.z
git push origin x.y.z
```

Compress the repository:

```sh
git archive -o publish.zip HEAD
```

And publish the haxelib:

```sh
haxelib submit publish.zip
```

## TODO

- Add more unit tests related to sockets.
- Test [untested platforms](https://github.com/wikiti/extension-networking/wiki/Considerations#unsupporteduntested-platforms).

## Contributors

This project has been developed by:

| Avatar | Name | Nickname | Email |
| ------ | ---- | -------- | ----- |
| ![](http://www.gravatar.com/avatar/2ae6d81e0605177ba9e17b19f54e6b6c.jpg?s=64)  | Daniel Herzog | Wikiti | [info@danielherzog.es](mailto:info@danielherzog.es)

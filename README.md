
# WJHEventTap.framework

[![GitHub version](https://badge.fury.io/gh/jodyhagins%2FWJHEventTap.svg)](https://github.com/jodyhagins/WJHEventTap/releases) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/jodyhagins/WJHEventTap/master/LICENSE.md)

This is a simple framework that provides a basic ObjectiveC interface to creating and managing event taps.

## Installation
[Carthage](https://github.com/carthage/carthage) is the recommended way to install WJHEventTap.  Add the following to your Cartfile:

<pre>    github "jodyhagins/WJHEventTap"</pre>

For manual installation, I recommend adding the project as a subproject to your project or workspace and adding the framework as a target dependency.
 
## Usage 
Create a delegate to handle the event tap callbacks, and attach it to an event tap object.

The headers are fully documented.
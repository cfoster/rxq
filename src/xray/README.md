# xray

**xray** is a framework for writing XQuery unit tests on MarkLogic Server. Test cases are written as standard XQuery functions like this:  

```xquery
declare function string-equality-example()
{
  let $foo := "foo"
  return assert:equal($foo, "foo")
};
```

## Getting Started
* Clone/copy/symlink xray into the root directory of your project<br/>
`git submodule add git://github.com/robwhitby/xray.git` 
* Create an HTTP app server pointing to the root directory of your project.
* Check all is well at `http://server:port/xray/`
* Write some tests..


## Writing Tests
Tests are grouped into library modules in the xray test namespace, importing the xray assertions module along with the modules to be tested.

```xquery
xquery version "1.0-ml";
module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

import module namespace some-module = "http://some-module-to-test" at "/some-module-to-test.xqy";

declare function string-equality-example()
{
  let $foo := some-module:foo()
  return assert:equal($foo, "foo")
};

declare function multiple-assert-example()
{
  let $foo := some-module:foo()
  let $bar := "bar"
  return (
    assert:not-empty($foo),
    assert:equal($foo, "foo"),
    assert:not-equal($foo, $bar)
  )
};

(: more tests :)
```

## Invoking Tests
**xray** will find and execute all the test cases defined in a directory (including sub-directories), and can be told to execute a subset by specifying regex patterns to match tests by module name or test name.

* browser - `http://server:port/xray/`
* command line - test-runner.sh is a sample shell script, edit the default vars (tested on OSX only).
* invoke from xquery - import `src/xray.xqy` and call `xray:run-tests()`. See `index.xqy` for example.


## Parameters
`dir` - test directory path relative from the app server modules root. Optional, defaults to "test".

`modules` - regex match on module name. Optional, default to match all.

`tests` - regex match on test name. Optional, defaults to match all.

`format` - set output format to html, xml or text. Optional, defaults to html.

## Assertions
```xquery
assert:equal($actual as item()*, $expected as item()*)
```
```xquery
assert:not-equal($actual as item()*, $expected as item()*)
```
```xquery
assert:empty($actual as item()*)
```
```xquery
assert:not-empty($actual as item()*)
```
```xquery
assert:error($actual as item()*, $expected-error-name as xs:string)
```
See `src/assertions.xqy` for the assertion definitions.

## Setup and teardown functions
`setup()` and `teardown()` are special function signatures. If defined, `setup()` is invoked in a different transaction before any tests, so any database updates are visible to the tests. `teardown()` is executed after all tests in that module have finished.

See `test/tests.xqy` for an example.

## Ignoring Tests 
Tests can be ignored by addding the prefix `IGNORE` to the test function name.

```xquery
declare function IGNORE-this-test-will-be-ignored()
```

## Acknowledgements
Thanks to [John Snelson](http://github.com/jpcs) for the XQuery parser lifted from https://github.com/xquery/xquerydoc
&nbsp;
## Screenshots
![screenshot of html output](https://github.com/robwhitby/xray/raw/master/screenshot-html.png)
![screenshot of terminal output](https://github.com/robwhitby/xray/raw/master/screenshot-terminal.png)

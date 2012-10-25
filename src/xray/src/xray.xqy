xquery version "1.0-ml";

module namespace xray = "http://github.com/robwhitby/xray";
declare namespace test = "http://github.com/robwhitby/xray/test";
import module namespace utils = "http://github.com/robwhitby/xray/utils" at "utils.xqy";
declare default element namespace "http://github.com/robwhitby/xray";


declare function xray:run-tests(
  $test-dir as xs:string, 
  $module-pattern as xs:string?, 
  $test-pattern as xs:string?, 
  $format as xs:string?
) 
{
  let $modules := utils:get-modules($test-dir, fn:string($module-pattern))
  let $tests := 
    element tests {
      for $module in $modules
      let $fns := 
        try { utils:get-functions($module) }
        catch ($ex) { xray:error($ex) }
      where fn:exists($fns)
      return
        element module {
          attribute path { utils:relative-path($module) },
          if ($fns instance of element(error:error)) then $fns 
          else ( 
            xray:apply($fns[utils:get-local-name(.) = "setup"]),
            for $fn in $fns[fn:not(utils:get-local-name(.) = ("setup", "teardown"))]
            where fn:matches(utils:get-local-name($fn), fn:string($test-pattern))
            return xray:run-test($fn),
            xray:apply($fns[utils:get-local-name(.) = "teardown"])  
          )
        }
    }
  return
    utils:transform($tests, $test-dir, $module-pattern, $test-pattern, $format)
};


declare function xray:run-test(
  $fn as xdmp:function
) as element(test) 
{
  let $ignore := fn:starts-with(utils:get-local-name($fn), "IGNORE")
  let $test :=
    if ($ignore) then () 
    else 
      try { xray:apply($fn) }
      catch($ex) { element exception { xray:error($ex)} }
  return element test {
    attribute name { utils:get-local-name($fn) },
    attribute result { 
      if ($ignore) then "ignored"
      else if ($test/error:error or $test//descendant-or-self::assert[@result="failed"]) then "failed" 
      else "passed"
    },
    $test
  }
};


declare function xray:test-response(
  $assertion as xs:string, 
  $passed as xs:boolean, 
  $actual as item()*, 
  $expected as item()*
) as element(assert)
{
  element assert {
    attribute test { $assertion },
    attribute result { if ($passed) then "passed" else "failed" },
    element xray:actual { $actual },
    element xray:expected { $expected }
  }
};


declare function xray:apply($function as xdmp:function)
{
  xdmp:eval("
    declare variable $fn as xdmp:function external; 
    declare option xdmp:update 'true';
    xdmp:apply($fn)",
    (fn:QName("","fn"), $function),
    <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>
  )
};


declare function xray:error($ex as element(error:error)) 
as element(error:error)
{
  $ex
};

---
title: "__index horror"
date: 2019-08-14T19:47:59-04:00
draft: false
toc: false
images:
tags: 
  - lua
  - metatable
  - __index
---

# The problem
[Lua](https://www.lua.org/) is a great programming language, very nice for modding games and super simple.

lua has a feature called [metatables](https://www.lua.org/pil/13.html) they are super useful, this post talks about the metatable event `__index`

the `__index` metatable event allows you to do something special when a key is not found in a table, for example here is how it can be used to look in another table if a key is not found

```lua
backup  = {bar = 20}
myTable = {foo = 10}

setmetatable(myTable, { __index = backup })

print(myTable.foo) -- 10
print(myTable.bar) -- 20
```

this is great, now lets look at a what happened to me.

to set the scene, I was mocking an API so I could test that my library was calling the right functions.
This library was a wrapper around the api to provide additional functionality, this example is stupid but the real project can be found [here](https://gitlab.com/0u/coords)

Here's a simplified version of the mocked version of an api
```lua
local api = {}

-- record api calls in here so that
-- i can assert the right calls are made in tests.
api.calls = {}

function api.foo()
  print('foo!')
  table.insert(api.calls, 'foo')
end

function api.bar()
  print('bar!')
  table.insert(api.calls, 'bar')
end

return api
```

Now for our library (adding some great functionality!)
```lua
local api = require('api')
local lib = {}

function lib.foobar()
  api.foo()
  api.bar()
end

function lib.barfoo()
  api.bar()
  api.foo()
end

-- we want to be backwards compatible with the old API so if a function is not
-- found then look in the api table for it.
return setmetatable(lib, { __index = api })
```

Now for our library tests
```lua
local lib = require('lib')

-- test the foobar function
lib.foobar()
assert(lib.calls[1] == 'foo')
assert(lib.calls[2] == 'bar')

-- clear lib.calls then test the barfoo function
lib.calls = {}
lib.barfoo()
assert(lib.calls[1] == 'bar')
assert(lib.calls[2] == 'foo')
```

If you run this you'll get
```
foo!
bar!
bar!
foo!
lua: lib_test.lua:11: assertion failed!
stack traceback:
        [C]: in function 'assert'
        lib_test.lua:11: in main chunk
        [C]: in ?
```
What happened?!? we can see that the functions are called in the right order from the output.

## The bug

While *reading* `lib.calls` works fine, the key is not found then lua looks in the `__index` table, finds it and returns the value, it's just that *writing* works differently.

*writing* to a table in lua ignores `__index` and just adds the key to the uppermost table, so after the tests are ran the `lib` table looks like this (not exactly, the metatable is stored separately but this is a nice visualization)

```lua
{
  foobar = function() ... end,
  barfoo = function() ... end,

  calls  = {}
  __index = {
    calls = {'foo', 'bar', 'bar', 'foo'},
    foo = function() ... end,
    bar = function() ... end,
  },
}
```

see! `calls` was added to the uppermost table instead of in `__index`, the mocked api adds to the `calls` table local to itself and we get this nasty bug.

## The solution
It's a bit ugly but we can force lua to write to the `__index` table like this

```lua
getmetatable(lib).__index.calls = {}
```

That's about it, I hope you learned something and I hope you never need to go through debugging this :D

# WellCached

WellCached is a NSCache subclass that provides keyed subscripting, time-based key expiration, and a Rails-like `fetch` API that works with data from an asynchronous source.

[![Version](http://cocoapod-badges.herokuapp.com/v/WellCached/badge.png)](http://cocoadocs.org/docsets/WellCached)
[![Platform](http://cocoapod-badges.herokuapp.com/p/WellCached/badge.png)](http://cocoadocs.org/docsets/WellCached)
[![Build Status](https://travis-ci.org/ericallam/WellCached.png?branch=master)](https://travis-ci.org/ericallam/WellCached)


## Usage

WellCached includes a single class `ELAWellCached` that can be used exactly like `NSCache`:

```objc
ELAWellCached *cache = [ELAWellCached new];

[cache objectForKey:@"foo"]; // nil
[cache setObject@"bar" forKey:@"foo"];
[cache objectForKey:@"foo"]; // @"bar"
```

And, as long as your key conforms to the `NSCopying` protocol, you can use the NSDictionary-like keyed subscripting syntax:

```objc
ELAWellCached *cache = [ELAWellCached new];

cache[@"foo"]; // nil
cache[@"foo"] = @"bar";
cache[@"foo"]; // @"bar"
```

### Time-based expiration

Unlike NSCache, you can automatically expire objects in the cache by setting an expiration duration:

```objc
ELAWellCached *cache = [ELAWellCached cacheWithDefaultExpiringDuration:60]; // 60 seconds

cache[@"foo"] = @"bar";

// 61 seconds later:

cache["foo"]; // nil
```

Every object in the above cache automatically expires after the default expiration.  You can set a per-key expiration that overrides the default using `setObject:forKey:expirationInterval:`, like so:

```objc
ELAWellCached *cache = [ELAWellCached cacheWithDefaultExpiringDuration:60]; // 60 seconds

[cache setObject:@"bar" forKey:@"foo" expirationInterval:30];

// 31 seconds later

cache[@"foo"]; // nil
```

### Fetch

The "fetch" APIs work by giving you the opportunity to generate the cached-object in case of a cache miss by passing in a block. This makes the common scenario of attempting to get a cached object but getting a miss, causing the regeneration of the object, and then returning the regenerated result. So instead of this:

```objc
- (id)getExpensiveCalculation
{
   id result = self.cache[@"key"];

   if (result) { // if the result is cached, go ahead and return it
      return result;
   }

   // Not in the cache, so have to regenerate it and then set it in the cache
   result = [self generateExpensiveCalculation];
   self.cache[@"key"] = result;

   return result;
}
```

You can just write this:

```objc
- (id)getExpensiveCalculation
{
   return [self.cache fetch:@"key" generateOnMiss:id^{
      // This block called only if 'key' wasn't already in the cache
      return [self generateExpensiveCalculation]; 
   }]
}
```

To me this API "reads" better than the previous example; it becomes more obvious what's going on.

### Fetch w/Async data source

In the last example, things were simple in that our `generateExpensiveCalculation` method was synchronous, so we could just return it's result from the `generateOnMiss:` block to fill our cache on a cache-miss.  

If instead `generateExpensiveCalculation` is an asynchrounous method that takes a callback which returns it's result, this approach won't work because the `generateOnMiss:` block will finish executing before the asynchronous callback has a chance to run.

There is a different method you should use for a situation like this. In this example `generateExpensiveCalculation` is now an asynchronous method, which means that the top-level `getExpensiveCalculation` method also needs to be callback-based

```objc
- (void)getExpensiveCalculation:(void (^)(id))callback
{
    [self.cache fetch:@"key" generateOnMissAsync:^(ELAResultCallback resultCallback) {        
        // This block is called if 'key' isn't already in the cache

        [self generateExpensiveCalculation:^(id expensiveCalc){
            // Fill the cache with the result of the expensive calculation
            resultCallback(expensiveCalc);
        }];

    } result:^(id result) {
        // This block is called with either the already cached result,
        // Or the newly generated cached result 
        
        callback(result); // Returns back to whoever called getExpensiveCalculation
    }];
}
```

Both the synchronous and asynchronous `fetch` methods have variants that allow you to pass in custom expiration durations.

## Tests

To run the tests; clone the repo, install [xcpretty](https://github.com/supermarin/xcpretty), and run `rake test` from the root directory or open the "WellCache.xcworkspace" and run the Test target using `⌘U`

## Example

Most of the time, [NSURLCache](http://nshipster.com/nsurlcache/) is all you'll need for caching expensive operations, but there are a couple common instances where you don't have much control over the networking stack that's fetching the data, such as using a third-party API library that talks to their own server, or for example the Apple-supplied Directions API. 

So the example project in `Examples/WalkingDirections` makes use of `WellCached` to fetch and store the result of walking directions for each location in the table view.


### Without WellCached:

<img src='http://i.imgur.com/qKs0uk2.gif' width="350px" />

### With WellCached:

<img src='http://i.imgur.com/igkGSi9.gif' width="350px" />

Check out `MasterViewController.m` to see how `WellCached` is used.

## Requirements

No dependencies other than Foundation

## Installation

WellCached is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "WellCached"

Import the `ELAWellCached` header like this:

```objc
#import <WellCached/ELAWellCached.h>
```

## Roadmap

I intend to keep improving the thread-safetyness of this class and expand it's Unit and Integration tests, as well as ship in an actual app that I am working on, before cutting a version 1.0. The public API could change at any time between now and 1.0.  At 1.0 the API will considered stabilized and Semantic Versioning will be followed.

## Author

Eric Allam, eallam@gmail.com

## License

WellCached is available under the MIT license. See the LICENSE file for more info.

## Contributing

If you would like to contribute to this project, please fork this repo and create pull requests (on a branch, not master).

Make sure any code you write is backed by a Unit test.  Check out the `Tests/WellCachedTests.m` file for the exist tests. 


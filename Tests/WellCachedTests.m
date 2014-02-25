//
//  WellCachedTests.m
//  WellCachedTests
//
//  Created by Eric Allam on 23/02/2014.
//
//

#import <XCTest/XCTest.h>
#import <WellCached/ELAWellCached.h>

@interface WellCachedTests : XCTestCase

@end

// TODO:
// - what happens if the generateOnMissAsync callback is passed nil?

@implementation WellCachedTests

- (void)testActsLikeNormalCache
{
    ELAWellCached *cache = [ELAWellCached new];
    
    XCTAssertNil([cache objectForKey:@"foo"]);
    
    [cache setObject:@"bar" forKey:@"foo"];
    
    XCTAssertEqualObjects([cache objectForKey:@"foo"], @"bar");
}

- (void)testKeyedSubscripting
{
    ELAWellCached *cache = [ELAWellCached new];
    
    XCTAssertNil(cache[@"foo"]);
    
    cache[@"foo"] = @"bar";
    
    XCTAssertEqualObjects(cache[@"foo"], @"bar");
}

- (void)testInitializingWithDefaultCacheExpiringTime
{
    ELAWellCached *cache = [ELAWellCached cacheWithDefaultExpiringDuration:1]; // 1 second
    
    cache[@"foo"] = @"bar";
    
    XCTAssertEqualObjects(cache[@"foo"], @"bar");
    
    sleep(2); // sleep for 2 seconds
    
    XCTAssertNil(cache[@"foo"], @"The 'foo' cache item did not automatically expire after the default duration");
}

- (void)testFetch
{
    ELAWellCached *cache = [ELAWellCached new];
    
    id result = [cache fetch:@"foo" generateOnMiss:^id{
        return @"bar";
    }];
    
    XCTAssertEqualObjects(result, @"bar");
    
    __block BOOL handlerCalled = NO;
    
    [cache fetch:@"foo" generateOnMiss:^id{
        handlerCalled = YES;
        return nil;
    }];
    
    XCTAssertFalse(handlerCalled, @"The handler should not be called because there is already a cache-item for 'foo'");
}

- (void)testFetchWithExpiration
{
    ELAWellCached *cache = [ELAWellCached cacheWithDefaultExpiringDuration:1]; // 1 second
    
    cache[@"foo"] = @"bar";
    
    sleep(2);
    
    __block BOOL handlerCalled = NO;
    
    id result = [cache fetch:@"foo" generateOnMiss:^id{
        handlerCalled = YES;
        return @"baz";
    }];
    
    XCTAssertTrue(handlerCalled);
    
    XCTAssertEqualObjects(result, @"baz");
}

- (void)testFetchWithCustomExpiration
{
    ELAWellCached *cache = [ELAWellCached cacheWithDefaultExpiringDuration:60]; // 1 minute
    
    [cache fetch:@"foo" generateOnMiss:^id{
        return @"bar";
    } expirationInterval:1];
    
    sleep(2);
    
    XCTAssertNil(cache[@"foo"]);
}

- (void)testMultipleThreadsCallingFetchOnExpiredItem
{
    ELAWellCached *cache = [ELAWellCached cacheWithDefaultExpiringDuration:1]; // 1 second
    
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 4;
    queue.name = @"CacheAccessQueue";
    
    __block int handlerCalls = 0;
    
    [queue addOperationWithBlock:^{
        [cache fetch:@"foo" generateOnMiss:^id{
            @synchronized(cache){
                handlerCalls++;
            }
            return @"baz";
        }];
    }];
    
    [queue addOperationWithBlock:^{
        [cache fetch:@"foo" generateOnMiss:^id{
            @synchronized(cache){
                handlerCalls++;
            }
            
            return @"bin";
        }];
    }];
    
    [queue addOperationWithBlock:^{
        [cache fetch:@"foo" generateOnMiss:^id{
            @synchronized(cache){
                handlerCalls++;
            }
            
            return @"bab";
        }];
    }];
    
    [queue waitUntilAllOperationsAreFinished];
    
    XCTAssertEqual(handlerCalls, 1);
}

- (void)testAsynchronousFetchHandlerWithCacheMiss
{
    ELAWellCached *cache = [ELAWellCached new];
    
    __block BOOL handlerCalled = NO;
    __block id result;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [cache fetch:@"foo" generateOnMissAsync:^(ELAResultCallback callback) {
        handlerCalled = YES;
        
        [[NSOperationQueue new] addOperationWithBlock:^{
            callback(@"bar");
            dispatch_semaphore_signal(sema);
        }];
    } result:^(id callResult) {
        result = callResult;
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue(handlerCalled);
    
    XCTAssertEqualObjects(@"bar", result);
}

- (void)testAsynchronousFetchHandlerWithCacheHit
{
    ELAWellCached *cache = [ELAWellCached new];
    
    __block BOOL handlerCalled = NO;
    __block id result;
    
    cache[@"foo"] = @"baz";
    
    [cache fetch:@"foo" generateOnMissAsync:^(ELAResultCallback callback) {
        handlerCalled = YES;
        
        [[NSOperationQueue new] addOperationWithBlock:^{
            callback(@"bar");
        }];
    } result:^(id callResult) {
        result = callResult;
    }];
    
    XCTAssertFalse(handlerCalled);
    
    XCTAssertEqualObjects(@"baz", result);
}

- (void)testAsynchronousFetchHandlerWithCustomExpirationInterval
{
    ELAWellCached *cache = [ELAWellCached cacheWithDefaultExpiringDuration:60]; // 1 minute
    
    __block id result;
    
    [cache fetch:@"foo" generateOnMissAsync:^(ELAResultCallback callback) {
        callback(@"bar");
    } result:^(id callResult) {
        result = callResult;
    } expirationInterval:1];
    
    sleep(2);
    
    XCTAssertNil(cache[@"foo"]);
}

@end

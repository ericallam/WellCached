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

@implementation WellCachedTests

- (void)testActsLikeNormalCache
{
    ELAWellCached *wellCached = [ELAWellCached new];
    
    XCTAssertNil([wellCached objectForKey:@"foo"]);
    
    [wellCached setObject:@"bar" forKey:@"foo"];
    
    XCTAssertEqualObjects([wellCached objectForKey:@"foo"], @"bar");
}

- (void)testKeyedSubscripting
{
    ELAWellCached *wellCached = [ELAWellCached new];
    
    XCTAssertNil(wellCached[@"foo"]);
    
    wellCached[@"foo"] = @"bar";
    
    XCTAssertEqualObjects(wellCached[@"foo"], @"bar");
}

- (void)testInitializingWithDefaultCacheExpiringTime
{
    ELAWellCached *wellCached = [ELAWellCached cacheWithDefaultExpiringDuration:1]; // 1 second
    
    wellCached[@"foo"] = @"bar";
    
    XCTAssertEqualObjects(wellCached[@"foo"], @"bar");
    
    sleep(2); // sleep for 2 seconds
    
    XCTAssertNil(wellCached[@"foo"], @"The 'foo' cache item did not automatically expire after the default duration");
}

- (void)testFetch
{
    ELAWellCached *wellCached = [ELAWellCached new];
    
    id result = [wellCached fetch:@"foo" generateOnMiss:^id{
        return @"bar";
    }];
    
    XCTAssertEqualObjects(result, @"bar");
    
    __block BOOL handlerCalled = NO;
    
    [wellCached fetch:@"foo" generateOnMiss:^id{
        handlerCalled = YES;
        return nil;
    }];
    
    XCTAssertFalse(handlerCalled, @"The handler should not be called because there is already a cache-item for 'foo'");
}

- (void)testMultipleThreadsCallingFetchOnExpiredItem
{
    ELAWellCached *wellCached = [ELAWellCached cacheWithDefaultExpiringDuration:1]; // 1 second
    
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 4;
    queue.name = @"CacheAccessQueue";
    
    __block int handlerCalls = 0;
    
    [queue addOperationWithBlock:^{
        [wellCached fetch:@"foo" generateOnMiss:^id{
            @synchronized(wellCached){
                handlerCalls++;
            }
            return @"baz";
        }];
    }];
    
    [queue addOperationWithBlock:^{
        [wellCached fetch:@"foo" generateOnMiss:^id{
            @synchronized(wellCached){
                handlerCalls++;
            }
            
            return @"bin";
        }];
    }];
    
    [queue addOperationWithBlock:^{
        [wellCached fetch:@"foo" generateOnMiss:^id{
            @synchronized(wellCached){
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

@end

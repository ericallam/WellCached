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

@end

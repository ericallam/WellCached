#import <Foundation/Foundation.h>

@interface ELAWellCached : NSCache

@property (assign, nonatomic, readonly) NSTimeInterval expireDuration;

+ (instancetype)cacheWithDefaultExpiringDuration:(NSTimeInterval)expireInterval;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end
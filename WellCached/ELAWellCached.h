#import <Foundation/Foundation.h>

typedef void (^ELAFetchCallback)(id);
typedef void (^ELAResultCallback)(id);

@interface ELAWellCached : NSCache

@property (assign, nonatomic, readonly) NSTimeInterval expireDuration;

+ (instancetype)cacheWithDefaultExpiringDuration:(NSTimeInterval)expireInterval;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

- (id)fetch:(id)key generateOnMiss:(id (^)(void))handler;
- (void)fetch:(id)key generateOnMissAsync:(void (^)(ELAResultCallback))handler result:(ELAFetchCallback)fetchCallback;
@end
#import <Foundation/Foundation.h>

typedef void (^ELAFetchCallback)(id);
typedef void (^ELAResultCallback)(id);

@interface ELAWellCached : NSCache

@property (assign, nonatomic, readonly) NSTimeInterval expireDuration;

+ (instancetype)cacheWithDefaultExpiringDuration:(NSTimeInterval)expireInterval;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

- (id)fetch:(id)key generateOnMiss:(id (^)(void))handler;
- (id)fetch:(id)key generateOnMiss:(id (^)(void))handler expirationInterval:(NSTimeInterval)interval;
- (void)fetch:(id)key generateOnMissAsync:(void (^)(ELAResultCallback))handler result:(ELAFetchCallback)fetchCallback;
- (void)fetch:(id)key
    generateOnMissAsync:(void (^)(ELAResultCallback))handler
                 result:(ELAFetchCallback)fetchCallback
     expirationInterval:(NSTimeInterval)interval;
@end
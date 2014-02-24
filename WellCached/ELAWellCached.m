#import "ELAWellCached.h"

@interface ELAWellCached ()
@property (assign, nonatomic) NSTimeInterval expireDuration;
@property (strong, atomic) NSMutableDictionary *expiringDates;
@end

@implementation ELAWellCached

#pragma mark - Initialization

+ (instancetype)cacheWithDefaultExpiringDuration:(NSTimeInterval)expireInterval;
{
    return [[self alloc] initWithDefaultExpiringDuration:expireInterval];
}

- (instancetype)initWithDefaultExpiringDuration:(NSTimeInterval)expireInterval
{
    if (self = [super init]) {
        self.expireDuration = expireInterval;
        self.expiringDates = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithDefaultExpiringDuration:60 * 60 * 24]; // Default is 1 day
}

#pragma mark - NSCache overrides

- (id)objectForKey:(id)key
{
    NSDate *expiringDate = self.expiringDates[key];
    
    if ([expiringDate compare:[NSDate date]] == NSOrderedAscending) {
        [self removeObjectForKey:key];
        [self.expiringDates removeObjectForKey:key];
    }

    return [super objectForKey:key];
}

- (void)setObject:(id)obj forKey:(id)key
{
    [self setObject:obj forKey:key expirationInterval:self.expireDuration];
}

- (void)setObject:(id)obj forKey:(id)key expirationInterval:(NSTimeInterval)expirationDuration
{
    self.expiringDates[key] = [NSDate dateWithTimeIntervalSinceNow:expirationDuration];
    
    [super setObject:obj forKey:key];
}

#pragma mark - New Api

- (id)fetch:(id)key generateOnMiss:(id (^)(void))handler;
{
    return [self fetch:key generateOnMiss:handler expirationInterval:self.expireDuration];
}

- (id)fetch:(id)key generateOnMiss:(id (^)(void))handler expirationInterval:(NSTimeInterval)interval;
{
    id result;
    
    @synchronized(self)
    {
        result = self[key];
        
        if (result) {
            return result;
        }
        
        result = handler();
        [self setObject:result forKey:key expirationInterval:interval];
    }
    
    return result;
}

- (void)fetch:(id)key
generateOnMissAsync:(void (^)(ELAResultCallback))handler
       result:(ELAFetchCallback)fetchCallback
expirationInterval:(NSTimeInterval)interval;
{
    @synchronized(self)
    {
        id result = self[key];
        
        if (result) {
            fetchCallback(result);
        }else{
            handler(^(id generatedResult){
                [self setObject:generatedResult forKey:key expirationInterval:interval];
                fetchCallback(generatedResult);
            });
        }
    }
}

- (void)fetch:(id)key generateOnMissAsync:(void (^)(ELAResultCallback))handler result:(ELAFetchCallback)fetchCallback;
{
    [self fetch:key generateOnMissAsync:handler result:fetchCallback expirationInterval:self.expireDuration];
}

#pragma mark - Keyed Subscripting

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
{
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
{
    [self setObject:obj forKey:key];
}

@end
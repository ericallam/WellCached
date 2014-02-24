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
    self.expiringDates[key] = [NSDate dateWithTimeIntervalSinceNow:self.expireDuration];
    
    [super setObject:obj forKey:key];
}

#pragma mark - New Api

- (id)fetch:(id)key generateOnMiss:(id (^)(void))handler;
{
    id result;
    
    @synchronized(self)
    {
        result = self[key];
        
        if (result) {
            return result;
        }
        
        result = handler();
        self[key] = result;
    }
    
    return result;
}

- (void)fetch:(id)key generateOnMissAsync:(void (^)(ELAResultCallback))handler result:(ELAFetchCallback)fetchCallback;
{
    @synchronized(self)
    {
        id result = self[key];
        
        if (result) {
            fetchCallback(result);
        }else{
            handler(^(id generatedResult){
                self[key] = generatedResult;
                fetchCallback(generatedResult);
            });
        }
    }
    
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
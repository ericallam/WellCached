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
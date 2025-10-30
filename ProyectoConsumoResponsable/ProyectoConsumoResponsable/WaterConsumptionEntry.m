//  WaterConsumptionEntry.m

#import "WaterConsumptionEntry.h"

@implementation WaterConsumptionEntry

-(instancetype)initWithLiters:(double)liters onDate:(NSDate *)date{
    self = [super init];
    if(self){
        _litersConsumed = liters;
        _date = date;
    }
    return self;
}

#pragma mark - NSCoding Protocol
-(void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeDouble:self.litersConsumed forKey:@"litersConsumed"];
}

-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super init];
    if(self){
        _date = [coder decodeObjectOfClass:[NSDate class] forKey:@"date"];
        _litersConsumed = [coder decodeDoubleForKey:@"litersConsumed"];
    }
    return  self;
}

+(BOOL)supportsSecureCoding{
    return YES;
}

@end

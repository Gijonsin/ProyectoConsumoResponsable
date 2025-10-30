//  WaterConsumptionEntry.h

#import <Foundation/Foundation.h>

@interface WaterConsumptionEntry : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) double litersConsumed;

- (instancetype)initWithLiters:(double)liters onDate:(NSDate *)date;

@end

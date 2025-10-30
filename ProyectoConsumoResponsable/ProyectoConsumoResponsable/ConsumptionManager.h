//  ConsumptionManager.h

#import <Foundation/Foundation.h>
#import "WaterConsumptionEntry.h"
NS_ASSUME_NONNULL_BEGIN

extern NSString *const ConsumptionDataDidUpdateNotification;

@interface ConsumptionManager : NSObject

@property (nonatomic, strong) NSMutableArray<WaterConsumptionEntry *> *allConsumptionEntries;

+ (instancetype)sharedManager;

-(void)registerConsumption:(double)liters;

-(NSDictionary<NSString *, NSNumber *> *)getConsumptionSummaryForLastDays:(NSInteger)days;

-(double)getTotalConsumptionForToday;
-(BOOL)isConsumptionOverThresholdForToday:(double)threshold;

// <--- DECLARACIÓN CRÍTICA AÑADIDA
+ (NSString *)getWaterSavingRecommendation;

@end

NS_ASSUME_NONNULL_END

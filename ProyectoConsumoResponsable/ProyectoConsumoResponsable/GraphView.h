//  GraphView.h

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GraphView : NSView

@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *dataToDisplay;
@property (nonatomic, strong) NSString *graphTitle;
@property (nonatomic, assign) BOOL isWeekly;
@end

NS_ASSUME_NONNULL_END

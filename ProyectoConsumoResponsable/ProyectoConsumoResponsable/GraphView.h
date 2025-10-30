//  GraphView.h

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GraphView : NSView

@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *dataToDisplay;

@end

NS_ASSUME_NONNULL_END

//  ViewController.h

#import <Cocoa/Cocoa.h>
#import "GraphView.h" // <--- Importante para el casting

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *litersInputTextField;
@property (weak) IBOutlet NSTextField *alertMessageLabel;
@property (weak) IBOutlet NSTextField *recommendationLabel;

// Estos Outlets están conectados a los NSBox del Storyboard
@property (weak) IBOutlet NSBox *weeklyGraphBox;
@property (weak) IBOutlet NSBox *monthlyGraphBox;

- (IBAction)registerConsumptionAction:(id)sender;

@end

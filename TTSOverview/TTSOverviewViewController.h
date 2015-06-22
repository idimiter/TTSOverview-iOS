
#import <UIKit/UIKit.h>

@class FliteTTS;
@class AVAudioPlayer;
@interface TTSOverviewViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate> {
	NSMutableArray* voicesArray;
	NSInteger selectedVoiceIndex;

    IBOutlet UITextView *_textView;
    IBOutlet UIButton *_FliteButton;
    IBOutlet UIButton *_GoogleButton;

	FliteTTS *_fliteEngine;
    AVAudioPlayer *_googlePlayer;
}

- (IBAction)FliteTapped;
- (IBAction)GoogleTapped;
- (IBAction)VoiceTapped;

- (void)runFlite:(NSString *)text;
- (void)runGoogle:(NSString *)text;



@end

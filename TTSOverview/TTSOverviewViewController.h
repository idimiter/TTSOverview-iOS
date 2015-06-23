
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "JuliusCSR .h"

@class FliteTTS;
@class AVAudioPlayer;

@interface TTSOverviewViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, AVAudioRecorderDelegate, JuliusDelegate> {
	NSMutableArray* voicesArray;
	NSInteger selectedVoiceIndex;

    IBOutlet UITextView *_textView;
    IBOutlet UIButton *_FliteButton;
	IBOutlet UIButton *_GoogleButton;
	IBOutlet UIButton *_SetVoiceButton;
	IBOutlet UIButton *_RecordButton;

	FliteTTS *_fliteEngine;
    AVAudioPlayer *_googlePlayer;
}

- (IBAction)FliteTapped;
- (IBAction)GoogleTapped;
- (IBAction)VoiceTapped;
- (IBAction)RecordTapped;

- (void)runFlite:(NSString *)text;
- (void)runGoogle:(NSString *)text;


@property (nonatomic, assign) BOOL processing;
@property (nonatomic, retain) AVAudioRecorder *recorder;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) Julius *julius;

@end

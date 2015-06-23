
#import <AVFoundation/AVFoundation.h>
#import "TTSOverviewViewController.h"
#import "FliteTTS.h"
#import "DDActivityView.h"

@implementation TTSOverviewViewController {
	DDActivityView *activityView;
}

@synthesize processing;
@synthesize recorder;
@synthesize julius;
@synthesize filePath;

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		voicesArray = [NSMutableArray arrayWithArray:@[@"cmu_us_kal",
													   @"cmu_us_kal16",
													   @"cmu_us_rms",
													   @"cmu_us_awb",
													   @"cmu_us_slt",

													   @"cmu_us_fem.flitevox",
													   @"cmu_us_clb.flitevox",
													   @"cmu_us_awb.flitevox"
													   ]];
		selectedVoiceIndex = 4;
		[voicesArray retain];
	}

	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

    _textView.editable = YES;
	_fliteEngine = [[FliteTTS alloc] init];

	// Activity View
	activityView = [[DDActivityView alloc] init];
	[self.view addSubview:activityView];

	// Swipe down to dismiss keyboard
	UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:_textView action:@selector(resignFirstResponder)];
	[swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
	[self.view addGestureRecognizer:swipeRecognizer];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI
- (IBAction)FliteTapped {
    [self runFlite:_textView.text];
}

- (IBAction)GoogleTapped {
    [self runGoogle:_textView.text];
}

-(IBAction)RecordTapped {
	if (!processing) {
		[self recording];

		[_RecordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		[_RecordButton setTitle:@"Stop" forState:UIControlStateNormal];

	} else {
		[recorder stop];

		[_RecordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_RecordButton setTitle:@"Record" forState:UIControlStateNormal];
	}

	self.processing = !processing;
}


#pragma mark Recognition
- (void)recording {

	// Create file path.
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yMMddHHmmss"];
	NSString *fileName = [NSString stringWithFormat:@"%@.wav", [formatter stringFromDate:[NSDate date]]];
	[formatter release];

	self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];

	// Change Audio category to Record.
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];

	// Settings for AVAAudioRecorder.
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM], AVFormatIDKey,
							  [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
							  [NSNumber numberWithUnsignedInt:1], AVNumberOfChannelsKey,
							  [NSNumber numberWithUnsignedInt:16], AVLinearPCMBitDepthKey,
							  nil];

	self.recorder = [[[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:filePath] settings:settings error:nil] autorelease];
	recorder.delegate = self;

	[recorder prepareToRecord];
	[recorder record];
}

- (void)recognition {
	if (!julius) {
		self.julius = [Julius new];
		julius.delegate = self;
	}

	[julius recognizeRawFileAtPath:filePath];
}

#pragma mark -
#pragma mark AVAudioRecorder delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
	if (flag) {
		[activityView start];
		[self performSelector:@selector(recognition) withObject:nil afterDelay:0.1];
	}
}


#pragma mark -
#pragma mark Julius delegate

- (void)callBackResult:(NSArray *)results {
	[activityView stop];

	// Show results.
	_textView.text = [results componentsJoinedByString:@" "];
}



- (IBAction)VoiceTapped {
	UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Voice Select" delegate:(self) cancelButtonTitle:nil destructiveButtonTitle:@"Done" otherButtonTitles: nil];
	[popup showInView:self.view];

	UIPickerView* pickerView = [[UIPickerView alloc] init];
	[pickerView setDataSource:self];
	[pickerView setDelegate:self];
	[pickerView setShowsSelectionIndicator:YES];
	[pickerView selectRow:selectedVoiceIndex inComponent:0 animated:NO];

	[popup setBounds:CGRectMake(0, 0, 320, 460)];

	//Displace all buttons
	NSInteger yOffset = 115;
	for (UIView *vButton in popup.subviews) {
		CGRect newFrame = vButton.frame;
		newFrame.origin.y = yOffset;
		vButton.frame = newFrame;
		yOffset += yOffset;
	}

	[popup addSubview:pickerView];
}

#pragma mark - Synthesizers
- (void)runFlite:(NSString *)text {
    [_fliteEngine speakText:text];
}

- (void)runGoogle:(NSString *)text {
    NSLog(@"GoogleTTS is executed");
    NSString *queryTTS = [text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *linkTTS = [NSString stringWithFormat:@"http://translate.google.com/translate_tts?tl=en&q=%@",queryTTS];
    
    NSData *dataTTS = [NSData dataWithContentsOfURL:[NSURL URLWithString:linkTTS]];
    
    _googlePlayer = [[AVAudioPlayer alloc] initWithData:dataTTS error:nil]; 
    [_googlePlayer play];
}


#pragma mark UIPickerViewDataSource methods
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return voicesArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

#pragma mark UIPickerViewDelegate methods
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	selectedVoiceIndex = row;
	[_fliteEngine setVoice:[voicesArray objectAtIndex:row]];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [voicesArray objectAtIndex:row];
}

#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
	[popup dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end

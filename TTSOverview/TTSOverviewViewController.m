
#import <AVFoundation/AVFoundation.h>
#import "TTSOverviewViewController.h"
#import "FliteTTS.h"

@implementation TTSOverviewViewController

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

- (IBAction)VoiceTapped {
	UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Voice Select" delegate:(self) cancelButtonTitle:nil destructiveButtonTitle:@"Done" otherButtonTitles: nil];
	[popup showInView:self.view];

	UIPickerView* pickerView = [[UIPickerView alloc] init];
	[pickerView setDataSource:self];
	[pickerView setDelegate:self];
	[pickerView setShowsSelectionIndicator:YES];
	[pickerView selectRow:selectedVoiceIndex inComponent:0 animated:NO];
/*
	//expand the action sheet
	CGRect rect = popup.frame;
	rect.size.height += 320;
	rect.origin.y -= 100;
	popup.frame = rect;
*/
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
	NSLog(@"Selected %d: %@", row, [voicesArray objectAtIndex:row]);
	selectedVoiceIndex = row;
	[_fliteEngine setVoice:[voicesArray objectAtIndex:row]];

//	[pickerView removeFromSuperview];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [voicesArray objectAtIndex:row];
}

#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"Button %d", buttonIndex);

	[popup dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end

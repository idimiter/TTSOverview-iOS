//
//  DDActivityView.m
//  TTSOverview
//
//  Created by Dimitar Dimitrov on 6/23/15.
//
//

#import "DDActivityView.h"

@implementation DDActivityView {
	UIActivityIndicatorView *activityIndicator;
}

-(id) init {
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];

	if (self) {
		CGPoint center = self.center;

		self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];

		UIView* pad = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 170)];
		pad.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
		pad.center = self.center;
		[pad.layer setCornerRadius:30.0f];
		[pad.layer setShadowColor:[UIColor blackColor].CGColor];
		[pad.layer setShadowOpacity:0.8];
		[pad.layer setShadowRadius:3.0];
		[pad.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
		[self addSubview:pad];

		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.center = self.center;
		[self addSubview:activityIndicator];

		UILabel* loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
		loadingLabel.text = @"Processing...";
		loadingLabel.backgroundColor = [UIColor clearColor];
		[loadingLabel setTextColor:[UIColor whiteColor]];
		[loadingLabel setTextAlignment:NSTextAlignmentCenter];

		center.y -= 50;
		loadingLabel.center = center;

		[self addSubview:loadingLabel];

		[self setHidden:YES];
	}

	return self;
}

-(void) start {
	[self setHidden:NO];
	[activityIndicator startAnimating];
}

-(void) stop {
	[self setHidden:YES];
	[activityIndicator stopAnimating];
}

@end

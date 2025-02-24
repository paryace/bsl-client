//
//	ReaderMainToolbar.m
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"

#import <MessageUI/MessageUI.h>

@implementation ReaderMainToolbar

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 28.0f

#define DONE_BUTTON_WIDTH 50.0f
#define THUMBS_BUTTON_WIDTH 40.0f
#define PRINT_BUTTON_WIDTH 40.0f
#define EMAIL_BUTTON_WIDTH 40.0f
#define MARK_BUTTON_WIDTH 40.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;
@synthesize searchButton;
@synthesize shareButton;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [self initWithFrame:frame document:nil];
}

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(object != nil); // Check

	if ((self = [super initWithFrame:frame]))
	{
		CGFloat viewWidth = self.bounds.size.width;

		UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H.png"];
		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N.png"];

		UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];

		CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));

		CGFloat leftButtonX = BUTTON_X; // Left button start X position

#if (READER_STANDALONE == FALSE) // Option

		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];

		doneButton.frame = CGRectMake(leftButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
		[doneButton setTitle:@" 返回" forState:UIControlStateNormal];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"BackButtonItem.png"] forState:UIControlStateNormal];
		//[doneButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		//[doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		//[doneButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		//[doneButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        //[doneButton.titleLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
        //[doneButton.titleLabel setShadowColor:[UIColor grayColor]];
		doneButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:doneButton];
        
        leftButtonX += (DONE_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
      /*  //added by Joy Zeng 2012/9/18
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar setFrame:CGRectMake(100, 0, 100, 44)];
        [[searchBar.subviews objectAtIndex:0]removeFromSuperview];
        [self addSubview:searchBar];
        self.searchBar=searchBar;
        [searchBar release];
        
        UIButton *lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
        lastButton.frame = CGRectMake(210, 0, 30, 44);
        [lastButton setTitle:@"last" forState:UIControlStateNormal];
		[lastButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[lastButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [lastButton addTarget:self action:@selector(lastButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lastButton];
        
       
       UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
       nextButton.frame = CGRectMake(250, 0, 40, 44);
       [nextButton setTitle:@"next" forState:UIControlStateNormal];
       [nextButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
       [nextButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
       [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
       [self addSubview:nextButton];

       
       */
        
               
        
               
        //end added
     

#endif // end of READER_STANDALONE Option

        
        
        
#if (READER_ENABLE_THUMBS == TRUE) // Option

		UIButton *thumbsButton = [UIButton buttonWithType:UIButtonTypeCustom];

		thumbsButton.frame = CGRectMake(leftButtonX, BUTTON_Y, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
		[thumbsButton setImage:[UIImage imageNamed:@"Reader-Thumbs.png"] forState:UIControlStateNormal];
		[thumbsButton addTarget:self action:@selector(thumbsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[thumbsButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[thumbsButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		thumbsButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:thumbsButton]; //leftButtonX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

#endif // end of READER_ENABLE_THUMBS Option

		CGFloat rightButtonX = viewWidth; // Right button start X position
        
        //搜索按钮
        rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);
        UIImage *eBookImage = [UIImage imageNamed: @"ButtonItem_Search"];
        UIButton *eBookButton = [[UIButton alloc] initWithFrame:CGRectMake(rightButtonX, BUTTON_Y, 42, 28) ];
        [eBookButton setBackgroundImage:eBookImage forState:UIControlStateNormal];
        [eBookButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [eBookButton.titleLabel setShadowColor:[UIColor grayColor]];
        [eBookButton.titleLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
        [eBookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [eBookButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
        eBookButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.searchButton=eBookButton;
        [self addSubview:eBookButton];
        [eBookButton release];
        
        // 分享按钮
        rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);
        UIImage *shareImage = [UIImage imageNamed:@"btn_share"];
        self.shareButton = [[[UIButton alloc] initWithFrame:CGRectMake(rightButtonX, BUTTON_Y, 42, 28)] autorelease];
        [shareButton setBackgroundImage:shareImage forState:UIControlStateNormal];
        [shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [shareButton.titleLabel setShadowColor:[UIColor grayColor]];
        [shareButton.titleLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:shareButton];
        

#if (READER_BOOKMARKS == TRUE) // Option

		rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];

		flagButton.frame = CGRectMake(rightButtonX, BUTTON_Y, MARK_BUTTON_WIDTH, BUTTON_HEIGHT);
		[flagButton setImage:[UIImage imageNamed:@"ButtonItem_Search"] forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(markButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[flagButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[flagButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

		[self addSubview:flagButton]; titleWidth -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		markButton = [flagButton retain]; markButton.enabled = YES; markButton.tag = NSIntegerMin;

		markImageN = [[UIImage imageNamed:@"ButtonItem_Search"] retain]; // N image
		markImageY = [[UIImage imageNamed:@"ButtonItem_Search"] retain]; // Y image

#endif // end of READER_BOOKMARKS Option

#if (READER_ENABLE_MAIL == TRUE) // Option

		if ([MFMailComposeViewController canSendMail] == YES) // Can email
		{
			unsigned long long fileSize = [object.fileSize unsignedLongLongValue];

			if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
			{
				rightButtonX -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);

				UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];

				emailButton.frame = CGRectMake(rightButtonX, BUTTON_Y, EMAIL_BUTTON_WIDTH, BUTTON_HEIGHT);
				[emailButton setImage:[UIImage imageNamed:@"Reader-Email.png"] forState:UIControlStateNormal];
				[emailButton addTarget:self action:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
				[emailButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
				[emailButton setBackgroundImage:buttonN forState:UIControlStateNormal];
				emailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

				[self addSubview:emailButton]; titleWidth -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);
			}
		}

#endif // end of READER_ENABLE_MAIL Option

#if (READER_ENABLE_PRINT == TRUE) // Option

		if (object.password == nil) // We can only print documents without passwords
		{
			Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

			if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
			{
				rightButtonX -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);

				UIButton *printButton = [UIButton buttonWithType:UIButtonTypeCustom];

				printButton.frame = CGRectMake(rightButtonX, BUTTON_Y, PRINT_BUTTON_WIDTH, BUTTON_HEIGHT);
				[printButton setImage:[UIImage imageNamed:@"Reader-Print.png"] forState:UIControlStateNormal];
				[printButton addTarget:self action:@selector(printButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
				[printButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
				[printButton setBackgroundImage:buttonN forState:UIControlStateNormal];
				printButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

				[self addSubview:printButton]; titleWidth -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);
			}
		}

#endif // end of READER_ENABLE_PRINT Option

		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:19.0f]; // 19 pt
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
			titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumFontSize = 14.0f;
			titleLabel.text =object.PDFName; //[object.fileName stringByDeletingPathExtension];

			[self addSubview:titleLabel]; [titleLabel release];
		}
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[markButton release], markButton = nil;

	[markImageN release], markImageN = nil;
	[markImageY release], markImageY = nil;
    
    [searchButton release];searchButton=nil;
    [shareButton release];shareButton=nil;
	[super dealloc];
}

- (void)setBookmarkState:(BOOL)state
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? markImageY : markImageN);

			[markButton setImage:image forState:UIControlStateNormal];
		}

		markButton.tag = state; // Update bookmarked state tag
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		UIImage *image = (state ? markImageY : markImageN);

		[markButton setImage:image forState:UIControlStateNormal];
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    if ([delegate respondsToSelector:@selector(tappedInToolbar:doneButton:)])
    {
        [delegate tappedInToolbar:self doneButton:button];   
    }
}

- (void)thumbsButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    if ([delegate respondsToSelector:@selector(tappedInToolbar:thumbsButton:)])
    {
        [delegate tappedInToolbar:self thumbsButton:button];   
    }
}

- (void)printButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    if ([delegate respondsToSelector:@selector(tappedInToolbar:printButton:)])
    {
        [delegate tappedInToolbar:self printButton:button];   
    }
}

- (void)emailButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    if ([delegate respondsToSelector:@selector(tappedInToolbar:emailButton:)])
    {
        [delegate tappedInToolbar:self emailButton:button];   
    }
}

- (void)markButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    if ([delegate respondsToSelector:@selector(tappedInToolbar:markButton:)])
    {
        [delegate tappedInToolbar:self markButton:button];   
    }
}

-(void)search:(UIButton *)button{
    
    if ([delegate respondsToSelector:@selector(tappedInToolbar:searchButton:)])
    {
        [delegate tappedInToolbar:self searchButton:button];
    }

    
}

-(void)share:(UIButton *)button {
    if ([delegate respondsToSelector:@selector(tappedInToolbar:shareButton:)]) {
        [delegate tappedInToolbar:self shareButton:button];
    }
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://leichunfeng@csair.com"]];
}

@end

//
//  RCPopoverView.m
//  TakeOrder
//
//  Created by Robin Chou on 11/19/12.
//  Copyright (c) 2012 Robin Chou. All rights reserved.
//

#import "RCPopoverView.h"
#import <QuartzCore/QuartzCore.h>

@interface RCPopoverView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;

@end

@implementation RCPopoverView
@synthesize overlayWindow = _overlayWindow;

#pragma mark - Class Methods

+(RCPopoverView *)sharedView {
    static dispatch_once_t once;
    static RCPopoverView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[RCPopoverView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+(void)show
{
    [[RCPopoverView sharedView] showWithView:nil];
}

+(void)showWithView:(UIView *)popover
{
    [[RCPopoverView sharedView] showWithView:popover];
}

+(void)dismiss
{
    [[RCPopoverView sharedView] dismiss];
}

+(BOOL)isVisible {
    return ([RCPopoverView sharedView].alpha == 1);
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _inset_left = 20;
        _inset_top = 30;
    }
    return self;
}

-(void)showWithView:(UIView *)view
{
    if (view) {
        _popoverView = view;
    }
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.popoverView addGestureRecognizer:recognizer];
    
    if ([RCPopoverView isVisible]) {
        [RCPopoverView dismiss];
        return;
    }
    if (!self.superview) {
        [self.overlayWindow addSubview:self];
    }
    [self.overlayWindow setHidden:NO];
    
    if(self.alpha != 1) {
        [self setupPopover];
        
        [UIView animateWithDuration:0.30
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.alpha = 1;
                             CGRect frame = self.popoverView.frame;
                             frame.origin.x = _inset_left;
                             [self.popoverView setFrame:frame];
                         }
                         completion:^(BOOL finished){
                         }];
    }
    [self setNeedsDisplay];
}


-(void)dismiss
{
    [UIView animateWithDuration:0.30
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         float w = self.frame.size.width;
                         float h = self.frame.size.height;
                         [self.popoverView setFrame:CGRectMake(w, _inset_top+20.0, w-2*_inset_left, h-2*_inset_top-20.0)];
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3 animations:^{
                             self.alpha = 0;
                         } completion:^(BOOL finished) {
                             [_popoverView removeFromSuperview];
                             _popoverView = nil;
                             [_overlayWindow removeFromSuperview];
                             _overlayWindow = nil;
                         }];
                     }];
}

#pragma mark - Helper Methods

-(void)setupPopover
{
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    [self addSubview:_popoverView];
    [self.popoverView setFrame:CGRectMake(w, _inset_top+20.0, w-2*_inset_left, h-2*_inset_top-20.0)];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frame = self.popoverView.frame;
        if (frame.origin.x > self.frame.size.width/3) {
            [self dismiss];
        } else {
            //animate back to origin
            float w = self.frame.size.width;
            float h = self.frame.size.height;
            [UIView animateWithDuration:0.30 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.popoverView setFrame:CGRectMake(_inset_left, _inset_top+20.0, w-2*_inset_left, h-2*_inset_top-20.0)];
            } completion:nil];
        }
    }
}

- (UIWindow *)overlayWindow {
    if(!_overlayWindow) {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.backgroundColor = [UIColor clearColor];
        [_overlayWindow makeKeyAndVisible];
    }
    return _overlayWindow;
}

- (UIView *)popoverView {
    if(!_popoverView) {
        _popoverView = [[UIView alloc] initWithFrame:CGRectZero];
        self.popoverView.backgroundColor = [UIColor whiteColor];
        [self.popoverView.layer setCornerRadius:4.0];
        _popoverView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
//        Apply shadow
        [self.popoverView.layer setShadowRadius:5.0];
        [self.popoverView.layer setShadowOpacity:0.8];
        [self.popoverView.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.popoverView.layer setShadowOffset:CGSizeMake(0, 2.0)];
        
        self.popoverView.clipsToBounds = NO;
    }
    return _popoverView;
}

- (CGFloat)visibleKeyboardHeight {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    // Locate UIKeyboard.
    UIView *foundKeyboard = nil;
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        
        // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
        if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
            possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
        }
        
        if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
            foundKeyboard = possibleKeyboard;
            break;
        }
    }
    
    if(foundKeyboard && foundKeyboard.bounds.size.height > 100)
        return foundKeyboard.bounds.size.height;
    
    return 0;
}

@end

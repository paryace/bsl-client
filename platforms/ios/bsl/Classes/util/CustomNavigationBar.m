//
//  CustomNavigationBar.m
//  CSMBP
//
//  Created by Justin Yip on 3/8/12.
//  Copyright (c) 2012 Forever OpenSource Software Inc. All rights reserved.
//

#import "CustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

#import "objc/runtime.h"
#import "objc/message.h"


#define MAX_BACK_BUTTON_WIDTH 160.0
#define MIN_BACK_BUTTON_WIDTH 54.0

@implementation CustomNavigationBar
@synthesize navigationController;
@synthesize imageName;

- (void)drawRect:(CGRect)rect
{
    imageName = (imageName == nil) ? @"nav_bg.png" : imageName;
    UIImage *image = [UIImage imageNamed:imageName];
    [image stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    [image drawInRect:rect];
}

// Given the prpoer images and cap width, create a variable width back button
-(UIButton*) backButtonWith:(UIImage*)backButtonImage highlight:(UIImage*)backButtonHighlightImage leftCapWidth:(CGFloat)capWidth
{
    // store the cap width for use later when we set the text
    backButtonCapWidth = capWidth;
    
    // Create stretchable images for the normal and highlighted states
    UIImage* buttonImage = [backButtonImage stretchableImageWithLeftCapWidth:backButtonCapWidth topCapHeight:0.0];
    UIImage* buttonHighlightImage = [backButtonHighlightImage stretchableImageWithLeftCapWidth:backButtonCapWidth topCapHeight:0.0];
    
    // Create a custom button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Set the title to use the same font and shadow as the standard back button
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    
    // Set the break mode to truncate at the end like the standard back button
    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Inset the title on the left and right
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 10.0, 0, 3.0);
    
    // Make the button as high as the passed in image
    button.frame = CGRectMake(0, 0, 0, buttonImage.size.height/2);
    
    // Just like the standard back button, use the title of the previous item as the default back text
    [self setText:self.topItem.title onBackButton:button];
    
    // Set the stretchable images as the background for the button
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonHighlightImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonHighlightImage forState:UIControlStateSelected];
    
    // Add an action for going back
    [button addTarget:self action:@selector(didClickBack:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setText:@"" onBackButton:button];
    
    return button;
}

-(void) setText:(NSString*)text onBackButton:(UIButton*)backButton
{
    // Measure the width of the text
    CGSize textSize = [text sizeWithFont:backButton.titleLabel.font];
    // Change the button's frame. The width is either the width of the new text or the max width
    float width = (textSize.width + (backButtonCapWidth * 1.5));
    width = width > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : width;
    width = width < MIN_BACK_BUTTON_WIDTH ? MIN_BACK_BUTTON_WIDTH : width;
    
    backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, width, backButton.frame.size.height);
    
    // Set the text on the button
    [backButton setTitle:text forState:UIControlStateNormal];
}

- (void)didClickBack:(id)sender
{
    [navigationController popViewControllerAnimated:YES];
}

//-(void)addSubview:(UIView *)view
//{
//    if ([@"UINavigationItemButtonView" isEqualToString:NSStringFromClass(view.class)]) {
//        NSLog(@"add subview to bar: %@", view);
//        UIImage *bgImage = [UIImage imageNamed:@"header_leftbtn_nor.png"];
////        view = [[UIView alloc] initWithFrame:CGRectMake(5, 7, 49, 30)];
////        CALayer *layer = view.layer;
////        layer.contents = (id)[bgImage CGImage];
////        layer.backgroundColor = [[UIColor redColor] CGColor];
//
//
//        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        backButton.frame = CGRectMake(5, 7, 49, 30);
//        [backButton setBackgroundImage:bgImage forState:UIControlStateNormal];
//        view = backButton;
//        return;
//    }
//
//    [super addSubview:view];
//}

@end

@implementation UIViewController (CustomNavigationBarSwizzle)

- (void)viewDidLoad_CustomNavigationBar
{
    // Get our custom nav bar
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    
    if ([customNavigationBar respondsToSelector:@selector(backButtonWith:highlight:leftCapWidth:)]) {
        // Create a custom back button
        UIButton* backButton = [customNavigationBar backButtonWith:[UIImage imageNamed:@"nav_back@2x.png"] highlight:nil leftCapWidth:14.0];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    
    [self viewDidLoad_CustomNavigationBar];
}

- (void)customLoadView{
    if (self.nibName) {
        [[NSBundle mainBundle] loadNibNamed:self.nibName owner:self options:nil];
    } else {
        //
        [self customLoadView];
    }
}

//- (void)customBundleLocalizedStringForKey:(NSString*)key value:(NSString*)value table:(NSString*)table{
//    NSString *local = [[NSUserDefaults standardUserDefaults] objectForKey:@"LOCAL"];
//
//    if (local == nil) {
//        local = @"zh-Hans";
//    }
//
//
//    NSString *directoryName = [NSString stringWithFormat:@"%@.lproj",local];
//
//    NSString *tableName = [NSString stringWithFormat:@"%@/Root",directoryName];
//
//    [self customBundleLocalizedStringForKey:key value:value table:tableName];
//}

@end

static void swizzle(Class c, SEL old, SEL new)
{
    Method oldMethod = class_getInstanceMethod(c, old);
    Method newMethod = class_getInstanceMethod(c, new);
    
    if (class_addMethod(c, old, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, new, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    }else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

void swizzleAllUIViewController()
{
    swizzle([UIViewController class], @selector(viewDidLoad), @selector(viewDidLoad_CustomNavigationBar));
    swizzle([UIViewController class], @selector(loadView), @selector(customLoadView));
    //    swizzle([NSBundle class], @selector(localizedStringForKey:value:table:), @selector(customBundleLocalizedStringForKey:value:table:));
}

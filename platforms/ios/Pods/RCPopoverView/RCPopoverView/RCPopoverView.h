//
//  RCPopoverView.h
//  RCPopoverView
//
//  Created by Robin Chou on 11/19/12.
//  Copyright (c) 2012 Robin Chou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCPopoverView : UIView

@property (nonatomic, assign) CGFloat inset_top;
@property (nonatomic, assign) CGFloat inset_left;
@property (nonatomic, strong) UIView *popoverView;

// Public Methods
+(void)show;
+(void)showWithView:(UIView *)popover;
+(void)dismiss;

+(BOOL)isVisible;

@end
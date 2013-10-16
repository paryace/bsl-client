//
//  ImageScroller.h
//  cube-ios
//
//  Created by apple2310 on 13-9-10.
//
//

#import <UIKit/UIKit.h>
@interface ImageScroller : UIView{
    UIScrollView* scrollView;
    UIImageView* imageView;
}

-(void)showImage:(NSString*)url;

-(void)showInView:(UIView*)view;

@end

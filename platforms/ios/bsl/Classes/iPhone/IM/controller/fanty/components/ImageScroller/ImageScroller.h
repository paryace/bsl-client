//
//  ImageScroller.h
//  cube-ios
//
//  Created by apple2310 on 13-9-10.
//
//

#import <UIKit/UIKit.h>
@interface ImageScroller : UIView{
//    UIImageView* imageView;
    UIWebView* webView;
}

-(void)showImage:(NSString*)url;

-(void)showInView:(UIView*)view;

@end

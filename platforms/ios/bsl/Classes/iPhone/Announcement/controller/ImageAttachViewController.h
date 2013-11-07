//
//  ImageAttachViewController.h
//  bsl
//
//  Created by zhoujun on 13-11-6.
//
//

#import <UIKit/UIKit.h>
#import "MRZoomScrollView.h"
@interface ImageAttachViewController : UIViewController
{
    MRZoomScrollView *imageView;
}
@property(nonatomic,strong)NSString *filepath;
@end

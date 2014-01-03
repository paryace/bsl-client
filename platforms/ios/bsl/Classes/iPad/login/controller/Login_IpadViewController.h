//
//  Login_IpadViewController.h
//  cube-ios
//
//  Created by 东 on 5/30/13.
//
//

#import <UIKit/UIKit.h>
@class CubeWebViewController;
@interface Login_IpadViewController : UIViewController<UIPopoverControllerDelegate>{
    CubeWebViewController *aCubeWebViewController;
    UIPopoverController *popover;
}


@end

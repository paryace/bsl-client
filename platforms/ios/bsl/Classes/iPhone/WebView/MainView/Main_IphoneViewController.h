//
//  Main_IphoneViewController.h
//  cube-ios
//
//  Created by 东 on 8/2/13.
//
//

#import <UIKit/UIKit.h>

@class SkinView;
@class CubeWebViewController;

@interface Main_IphoneViewController : UIViewController{
    CubeWebViewController *aCubeWebViewController;
}

@property(nonatomic,strong) UINavigationController* navController;

@property (strong, nonatomic) NSString *selectedModule;
@end

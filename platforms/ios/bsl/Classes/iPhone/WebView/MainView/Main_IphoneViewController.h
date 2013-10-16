//
//  Main_IphoneViewController.h
//  cube-ios
//
//  Created by 东 on 8/2/13.
//
//

#import <UIKit/UIKit.h>


@class CubeWebViewController;

@interface Main_IphoneViewController : UIViewController{
    CubeWebViewController *aCubeWebViewController;
}

@property(nonatomic,strong) UINavigationController* navController;
@property(nonatomic,strong) CubeWebViewController *aCubeWebViewController;
@property (strong, nonatomic) NSString *selectedModule;
@end

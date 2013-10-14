//
//  MainViewViewController.h
//  cube-ios
//
//  Created by 东 on 6/4/13.
//
//

#import <UIKit/UIKit.h>

@class CubeWebViewController;
@class SkinView;
@interface MainViewViewController : UIViewController{
    UIViewController * detaselectedTabIndexilController;
    UIViewController * mainController;
    CubeWebViewController *aCubeWebViewController ;
    
    SkinView * skinView;
    UIButton* fullScreanBtn;
    BOOL isFullScrean;
    
    int selectedTabIndex;
}

@property(nonatomic,strong) UINavigationController* navController;

@end

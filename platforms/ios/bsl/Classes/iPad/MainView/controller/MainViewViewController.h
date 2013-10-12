//
//  MainViewViewController.h
//  cube-ios
//
//  Created by 东 on 6/4/13.
//
//

#import <UIKit/UIKit.h>
#import "CubeWebViewController.h"
#import "DownLoadingDetialViewController.h"
#import "SettingMainViewController.h"
#import "SkinView.h"
#import "FMDBManager.h"
#import "AutoDownLoadRecord.h"

typedef void (^DidFinishWebViewViewBlock)(void);


@interface MainViewViewController : UIViewController<DownloadCellDelegate,SettingMainViewControllerDelegate,SkinViewDelegate,UIGestureRecognizerDelegate>{
    UIViewController * detailController;
    UIViewController * mainController;
    CubeWebViewController *aCubeWebViewController ;
    
    SkinView * skinView;
    UIButton* fullScreanBtn;
    BOOL isFullScrean;
    
    int selectedTabIndex;
}

@property(nonatomic,strong) UINavigationController* navController;

@end

//
//  DownloadingViewController.h
//  Cube-iOS
//
//  Created by chen shaomou on 12/9/12.
//
//

//retina3.5
#define kOutSideViewFrame_retina3_5 CGRectMake(0,0,320,370)
#define kContentViewFrame_retina3_5 CGRectMake(0,0,320,370)
#define kTableViewFrame_retina3_5 CGRectMake(0,40,320,330)

//retina4
#define kOutSideViewFrame_retina4 CGRectMake(0,0,320,370+88)
#define kContentViewFrame_retina4 CGRectMake(0,0,320,370+88)
#define kTableViewFrame_retina4 CGRectMake(0,40,320,330+88)

#define kOutSideViewFrame (iPhone5?kOutSideViewFrame_retina4:kOutSideViewFrame_retina3_5)
#define kContentViewFrame (iPhone5?kContentViewFrame_retina4:kContentViewFrame_retina3_5)
#define kTableViewFrame (iPhone5?kTableViewFrame_retina4:kTableViewFrame_retina3_5)

#define kNumOfAppInDesktop 12
#define ORGIN_H_GAP 17
#define ORGIN_V_GAP 0
#define BETWEEN_H_GAP 10
#define BETWEEN_V_GAP 5
#define KCOLUMNCOUNT 4
#define kButtonWidth 64
#define kButtonHeight 90
#define kHeaderViewHeight 15
#define kHeaderGap 10
#import <UIKit/UIKit.h>
#import "DownloadingTableViewCell.h"
#import "IphoneDownloadingTableViewCell.h"
#import "BaseViewController.h"
#import "SearchDataSource.h"
typedef enum
{
    EAPPINSTALLED=0,
    EAPPUNINSTALLED,
    EAPPUPDATE
}appStatus;

@protocol DownloadTableDelegate <NSObject>
@optional
- (void)downloadAtModuleIdentifier:(NSString *)identifier andCategory:(NSString *)category;
- (void)deleteAtModuleIdentifier:(NSString *)identifier;
- (void)exitDownloadScreen;
@end

@interface DownloadingViewController : BaseViewController <UITableViewDataSource,UITableViewDelegate,DownloadCellDelegate,IconButtonDelegate,UIScrollViewDelegate,UIAlertViewDelegate>
{
    BOOL desktopIconEnable;     //TRUE: 桌面视图模式 FALSE:  列表视图模式
    
    int Select_Segment_index; //记录选中状态
    
    BOOL isGoTODetailView;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentCtr;

@property (weak, nonatomic) id<DownloadTableDelegate> delegate;
@property (assign, nonatomic) appStatus currentShowStatus;
@property (strong, nonatomic) UIScrollView *deskTopView;
@property (strong, nonatomic) UITableView *contentTableView;
@property (strong, nonatomic) UIView *viewContainer;
@property (strong, atomic) NSMutableArray *deskTopInfoArr;
@property (strong,nonatomic) UIView *searchBarView;
@property (strong,nonatomic) NSMutableDictionary *curDic;
//@property (retain, nonatomic) IBOutlet UIBarButtonItem *navRightButton;
//@property (retain, nonatomic) IBOutlet UIBarButtonItem *navLeftButton;
- (IBAction)exit:(id)sender;
- (IBAction)switchToListMode:(id)sender;
-(void)drawIconsPage:(NSMutableDictionary *)items;
@end

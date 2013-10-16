//
//  DownloadingViewController.m
//  Cube-iOS
//
//  Created by chen shaomou on 12/9/12.
//
//



#define kSearchCombineBar CGRectMake(0,0,320,40)  //搜索框的大小
#define kSearchBarHideFrame CGRectMake(0,-40,320,40)//搜索框隐藏的大小

//retina3.5
#define BUTTONGROUP_FRAME_retina3_5 CGRectMake(10, 380, 300, 30)
#define BUTTONGROUP_BG_FRAME_retina3_5 CGRectMake(0, 370, 320, 50)
//retina4
#define BUTTONGROUP_FRAME_retina4 CGRectMake(10, 380+88, 300, 30)
#define BUTTONGROUP_BG_FRAME_retina4 CGRectMake(0, 370+88, 320, 50)

#define BUTTONGROUP_FRAME (iPhone5?BUTTONGROUP_FRAME_retina4:BUTTONGROUP_FRAME_retina3_5)
#define BUTTONGROUP_BG_FRAME (iPhone5?BUTTONGROUP_BG_FRAME_retina4:BUTTONGROUP_BG_FRAME_retina3_5)
#define BACKGROUND_RGBA 0xf6f6f6

#import "DownloadingViewController.h"
#import "CubeApplication.h"
#import "CubeModule.h"
#import "FunctionDetialInfoViewController.h"
#import "SwitchButton.h"
#import "UIColor+expanded.h"
#import "ButtonGroup.h"

#import "DownLoadingDetialViewController.h"
#import "NSMutableDictionary+SortedAllkeys.h"



@interface DownloadingViewController ()

@property (strong,nonatomic) NSString *curFliterStr;

@property (strong,nonatomic) SwitchButton *tableSwitchBtn;
@property (strong,nonatomic) SwitchButton *desktopSwitchBtn;
@end

@implementation DownloadingViewController
@synthesize delegate;
@synthesize myCellConfig;


- (void)viewDidLoad{
    [super viewDidLoad];
    self.title=@"模块管理";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:CubeAppUpdateFinishNotification object:nil];
    
    
    if (currentDeviceIsIphone) {
        UIImageView* backgroundView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        backgroundView.image = [UIImage imageNamed:@"homebackImg.png"];
        [self.view  addSubview:backgroundView];
        
        //svsSegment
        UIImageView *buttonGroupBG = [[UIImageView alloc] initWithFrame:BUTTONGROUP_BG_FRAME];
        [buttonGroupBG setImage:[UIImage imageNamed:@"buttongroup_bg@2x.png"]];
        NSArray *titles = [[NSArray alloc] initWithObjects:@"未安装",@"已安装",@"待升级", nil];
        
        NSArray *imageNames = [[NSArray alloc] initWithObjects:@"left_button@2x.png",@"middle_button@2x.png",@"right_button@2x.png", nil];
        NSArray *activeImageNames = [[NSArray alloc] initWithObjects:@"left_button_active@2x.png",@"middle_button_active@2x.png",@"right_button_active@2x.png", nil];
        ButtonGroup *buttonGroup = [[ButtonGroup alloc] initWithFrame:BUTTONGROUP_FRAME ButtonTitle:titles andBackground:imageNames andActiveBackground:activeImageNames];
        
        buttonGroup.delegate = self;
         
        [self.view addSubview:buttonGroupBG];
        [self.view addSubview:buttonGroup];
        
        
        self.currentShowStatus=EAPPUNINSTALLED;
        //Ëß??ÂÆπÂ?
        UIView *container = [[UIView alloc]initWithFrame:kOutSideViewFrame];
        self.viewContainer= container;
        [self.view addSubview:self.viewContainer];
        
        //Ê°??Ëß??
        UIScrollView *desk = [[UIScrollView alloc]initWithFrame:kContentViewFrame];
        self.deskTopView = desk;
        self.deskTopView.tag = 78;
        
        //??°®Ëß??
        UITableView *tableView;
        if (currentDeviceIsIphone) {
            tableView = [[UITableView alloc]initWithFrame:kContentViewFrame style:UITableViewStyleGrouped];
        }else{
            tableView = [[UITableView alloc]initWithFrame:kContentViewFrame];
        }
        self.contentTableView = tableView;
        
        
        [_deskTopView addSubview:backgroundView];
        _deskTopView.backgroundColor = [UIColor clearColor];
        [self.viewContainer addSubview:backgroundView];
        
        self.contentTableView.backgroundView = backgroundView;
        self.contentTableView.delegate=self;
        self.contentTableView.dataSource=self;
        
        //???ËØ??ËÆæÁΩÆ‰∏?ableview
        desktopIconEnable=NO;
        [self.viewContainer addSubview:_contentTableView];
        self.contentTableView.tableHeaderView = nil;
        [self.view addSubview:self.viewContainer];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    
    isGoTODetailView = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:KNOTIFICATION_DETIALPAGE_INSTALLFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:KNOTIFICATION_DETIALPAGE_INSTALLSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:KNOTIFICATION_DETIALPAGE_DELETESUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:CubeSyncFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchTokemTimeOurInfoForFilter) name:CubeTokenTimeOutNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patchArrayInfoForFilter) name:CubeSyncFailedNotification object:nil];
    
    [self syncArrayInfo];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    for (UIView* view in self.contentTableView.subviews){
        if([view class ] == [IphoneDownloadingTableViewCell class]){
            IphoneDownloadingTableViewCell*cell = ( IphoneDownloadingTableViewCell*)view;
            if (cell.alertMessageView) {
                [cell.alertMessageView dismissWithClickedButtonIndex:1 animated:NO];
            }
        }
    }
    
    if (!isGoTODetailView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    self.tableView=nil;
    self.segmentCtr=nil;
    self.deskTopView=nil;
    self.contentTableView=nil;
    self.viewContainer=nil;
    self.deskTopInfoArr=nil;
    self.searchBarView=nil;
    self.curDic=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void)didClickButtonGroup:(NSNumber *)index{
 
    [self svsSegmentValueChanged:[index integerValue]];

}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

  
}

#pragma mark -- DownloadTableDelegate deleagte


- (void)downloadAtModuleIdentifier:(NSString *)identifier andCategory:(NSString *)category{
    
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    
    CubeModule *module = [cubeApp availableModuleForIdentifier:identifier];
    
    if(!module){
    
        module = [cubeApp updatableModuleModuleForIdentifier:identifier];
    }
    
    [cubeApp installModule:module];
    
    if (self.delegate&&[delegate respondsToSelector:@selector(downloadAtModuleIdentifier:)]) {
        [delegate downloadAtModuleIdentifier:identifier andCategory:category];
    }
}

-(void)deleteAtModuleIdentifier:(NSString *)identifier
{
    if (self.delegate&&[delegate respondsToSelector:@selector(deleteAtModuleIdentifier:)]) {
        [delegate deleteAtModuleIdentifier:identifier];
    }
}



- (void)clickItemWithIndex:(int)aIndex andIdentifier:(NSString*)aStr
{
    [self launch:aIndex identifier:aStr];
}
#pragma mark -- private method
//同步网络数据
-(void)syncArrayInfo{
    //同步网络数据
    [[CubeApplication currentApplication] sync];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeSyncFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeSyncFailedNotification object:nil];
}


-(void)patchTokemTimeOurInfoForFilter{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeTokenTimeOutNotification object:nil];
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (!(BOOL)[defaults objectForKey:@"offLineSwitch"]) {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"账号已在别处登录" delegate:self cancelButtonTitle:@"重新登录" otherButtonTitles:nil, nil];
        alertView.tag = 100;
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 0) {
         [(AppDelegate *)[UIApplication sharedApplication].delegate showLoginView];
    }
}

- (void)patchArrayInfoForFilter
{
    [SearchDataSource filterTheDataSources:self.curFliterStr forDelegate:self];
}

-(void)drawWithDataSource:(NSMutableDictionary*)tempDic{
    
    self.curDic = tempDic;

    if([[_deskTopView subviews] count] != 0){
        for(UIView *each in [_deskTopView subviews]){
            [each removeFromSuperview];
        }
    }
    
    [self drawIconsPage:_curDic];
    [self.contentTableView reloadData];
    
}

-(NSArray *)modulesToFilt{
    NSMutableArray *tempArr=[NSMutableArray array];
    if (self.currentShowStatus==EAPPINSTALLED) {
        tempArr=[[CubeApplication currentApplication] modules];
        self.myCellConfig = EDELETE;
    }else if (self.currentShowStatus==EAPPUNINSTALLED)
    {
        tempArr=[[CubeApplication currentApplication] availableModules];
        self.myCellConfig = EADD;
    }else if(self.currentShowStatus==EAPPUPDATE)
    {
        tempArr=[[CubeApplication currentApplication] updatableModules];
        self.myCellConfig = EUPDATE;
    }
    return tempArr;
}

-(void)saveCurrentIconDic:(NSMutableDictionary *)iconDic{
    self.curDic = iconDic;
}





-(void)drawIconsPage:(NSMutableDictionary *)items{
    
   
}



- (IBAction)exit:(id)sender {
    [delegate exitDownloadScreen];
}

-(void)moduleFinishDownload:(NSNotification *)notification{
    
    //    [self.tableView reloadData];
    //ÂΩ?®°???ËΩΩÂ??∂Â??∞‰?ËΩΩÁ????ÂΩ?‰∏?®°???‰π???∂‰?ËΩΩÂ??∂È?Â§????eloaddata
    [self.contentTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

}


//ÁøªËΩ¨
- (IBAction)switchToListMode:(id)sender {
    //???‰∏??
    

	// disable user interaction during the flip
    self.viewContainer.userInteractionEnabled = NO;
//	flipIndicatorButton.userInteractionEnabled = NO;
	
	// setup the animation group
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
	
    
    
	// swap the views and transition
    if (desktopIconEnable) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.viewContainer cache:YES];
        [self.viewContainer addSubview:_contentTableView];
        self.contentTableView.tableHeaderView = nil;  //‰∏??‰∏∫Â?,Ë¶??ËÆæÊ?nil???view???‰ª•Ê????Á§?
        [_deskTopView removeFromSuperview];
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.viewContainer cache:YES];
        [self.viewContainer addSubview:_deskTopView];
        [_contentTableView removeFromSuperview];
    }

	[UIView commitAnimations];
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
	[UIView commitAnimations];
    
    self.viewContainer.userInteractionEnabled = YES;
    desktopIconEnable=!desktopIconEnable;

}

//?®È?‰∏?ΩΩ
-(void)downloadAll{

    CubeApplication *app = [CubeApplication currentApplication];
    
    for(CubeModule *each in app.updatableModules){
        if(!each.isDownloading){
            if([delegate respondsToSelector:@selector(downloadAtModuleIdentifier:)])
                [delegate performSelector:@selector(downloadAtModuleIdentifier:) withObject:each.identifier];
            each.isDownloading = YES;
        }
    }
    for(CubeModule *each in app.availableModules){
        if(!each.isDownloading){
            if([delegate respondsToSelector:@selector(downloadAtModuleIdentifier:)])
                [delegate performSelector:@selector(downloadAtModuleIdentifier:) withObject:each.identifier];
            each.isDownloading = YES;
        }
    }
    
    //???‰∏????°®,Ë¶??Ëø?∫¶?°Â?‰∏??
    [[self contentTableView] reloadData];
}

#pragma mark svsSegment ValueChanged
- (void)svsSegmentValueChanged:(NSUInteger)newIndex{
    if (newIndex==0) {
        Select_Segment_index = 0;
        self.currentShowStatus=EAPPUNINSTALLED;
    }else if (newIndex==1)
    {
        Select_Segment_index = 1;
        self.currentShowStatus=EAPPINSTALLED;
    }else
    {
        Select_Segment_index = 2;
        self.currentShowStatus=EAPPUPDATE;
    }


    [SearchDataSource filterTheDataSources:self.curFliterStr forDelegate:self];

}


#pragma mark --- IconButtonDelegate
- (void)launch:(int)index identifier:(NSString *)identifier
{
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        NSMutableArray *modules  = [NSMutableArray array];
        
        [modules addObjectsFromArray:[cubeApp updatableModules]];
        [modules addObjectsFromArray:[cubeApp modules]];
        [modules addObjectsFromArray:[cubeApp availableModules]];
    
        DownLoadingDetialViewController *funDetialVC=[[DownLoadingDetialViewController alloc]init];
        for(CubeModule *each in modules){
            if([each.identifier isEqualToString:identifier]){
                funDetialVC.curCubeModlue=each;
                break;
            }
        }
    
        funDetialVC.delegate=self;
        if (_currentShowStatus==EAPPINSTALLED) {
            funDetialVC.buttonStatus = InstallButtonStateInstalled;
        }else if(_currentShowStatus==EAPPUNINSTALLED) {
            funDetialVC.buttonStatus = InstallButtonStateUninstall;
        }else{
            funDetialVC.buttonStatus = InstallButtonStateUpdatable;
        }
    
        if(funDetialVC.curCubeModlue.isDownloading){
            funDetialVC.iconImage=[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloading delegate:nil];
            
            funDetialVC.iconImage.downloadProgressView.progress = funDetialVC.curCubeModlue.downloadProgress;
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;
        }else
        {
            funDetialVC.iconImage =[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloadEnable delegate:nil];
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;

        }
    isGoTODetailView = true;
    
        [self.navigationController pushViewController:funDetialVC animated:YES];
}

- (void)download:(id)sender identifier:(NSString *)identifier{}
- (void)removeFromSpringboard:(int)index{}
- (void)removeEnuseableModuleFromSpringboard:(NSString *)identifier index:(int)index{}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    UIScrollView *tempScrollView=(UIScrollView*)sender;
    
    //?ªÊ?headerViewÁ≤??
    if (tempScrollView == self.contentTableView)
    {
        CGFloat sectionHeaderHeight = kHeaderViewHeight; //sectionHeaderHeight
        if (tempScrollView.contentOffset.y<=sectionHeaderHeight&&tempScrollView.contentOffset.y>=0) {
            tempScrollView.contentInset = UIEdgeInsetsMake(-tempScrollView.contentOffset.y, 0, 0, 0);
        } else if (tempScrollView.contentOffset.y>=sectionHeaderHeight) {
            tempScrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
}



#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.curDic count]!=0){
        _contentTableView.frame=([[self.curDic sortedAllkeys] count]==0)?CGRectZero:kContentViewFrame;
        return [[self.curDic sortedAllkeys] count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (currentDeviceIsIphone) {
        NSString *key = [[self.curDic sortedAllkeys] objectAtIndex:section];
        return  [[self.curDic objectForKey:key] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        return 75;
    }else{
        return 148;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderViewHeight + 20;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        CubeApplication *app = [CubeApplication currentApplication];
        
        UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320  , kHeaderViewHeight)];
        
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 80, 40)];
        titleLabel.font=[UIFont systemFontOfSize:12];
        titleLabel.textColor=[UIColor grayColor];
        titleLabel.minimumFontSize=8;
        titleLabel.adjustsFontSizeToFitWidth=TRUE;
        titleLabel.backgroundColor=[UIColor clearColor];
        [headerView addSubview:titleLabel];
        
        if (self.currentShowStatus==EAPPINSTALLED) {
            NSLog(@"test:%@",[[CubeApplication sortByCategroy:app.modules]  sortedAllkeys]);
            titleLabel.text=[NSString stringWithFormat:@"%@",[[self.curDic  sortedAllkeys] objectAtIndex:section]];
        }else if (self.currentShowStatus==EAPPUPDATE){
            if(app.updatableModules.count !=0){
                titleLabel.text=[NSString stringWithFormat:@"%@",[[self.curDic  sortedAllkeys] objectAtIndex:section]];
            }
        }else{
            titleLabel.text=[NSString stringWithFormat:@"%@",[[self.curDic  sortedAllkeys] objectAtIndex:section]];
        }
        return headerView;
    }
    return nil;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"IphoneDownloadingTableViewCell";

    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone) {
        IphoneDownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[IphoneDownloadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        // Configure the cell...
        cell.delegate = self;
        
        NSString *key = [[self.curDic sortedAllkeys] objectAtIndex:indexPath.section];
        NSMutableArray *modules = [self.curDic objectForKey:key];
        
        CubeModule *tempModule = [[CubeApplication currentApplication] moduleForIdentifier:[[modules objectAtIndex:indexPath.row] identifier]];
        //‰∏∫Á©∫???Â∞±‰?‰∏?ΩΩ????ªÂ???
        if (!tempModule) {
            tempModule=[[CubeApplication currentApplication] availableModuleForIdentifier:[[[_curDic objectForKey:key] objectAtIndex:indexPath.row] identifier]];
        }
        
        if (self.currentShowStatus==EAPPINSTALLED) {
            [cell configWithModule:tempModule andConfig:EDELETE];
        }else if (self.currentShowStatus==EAPPUNINSTALLED)
        {
            [cell configWithModule:tempModule andConfig:EADD];
        }else if(self.currentShowStatus==EAPPUPDATE)
        {
            [cell configWithModule:[[CubeApplication currentApplication] updatableModuleModuleForIdentifier:tempModule.identifier] andConfig:EUPDATE];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        cell.infoLabel.backgroundColor = [UIColor clearColor];
        cell.versionLabel.backgroundColor = [UIColor clearColor];
        cell.releasenoteLabel.backgroundColor = [UIColor clearColor];
        
        cell.nameLabel.hidden = YES;
        cell.iconButton.badgeView.hidden = YES;
        [cell.iconButton removeNotification];
        
        return cell;
    }else{
        DownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DownloadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        // Configure the cell...
        cell.delegate = self;
        
        CubeApplication *app = [CubeApplication currentApplication];
        
        if(indexPath.section == 0){
            [cell configWithModule:[app.updatableModules objectAtIndex:indexPath.row]];
        }
        
        if(indexPath.section == 1){
            [cell configWithModule:[app.availableModules objectAtIndex:indexPath.row]];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
       
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (currentDeviceIsIphone) {
        return nil;
    }
    if(section == 0)
        return @"?¥Ê?";
    if(section == 1)
        return @"Ê∑ªÂ?";
    
    return @"";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (currentDeviceIsIphone) {
         DownLoadingDetialViewController *funDetialVC=[[DownLoadingDetialViewController alloc]init];
       CubeApplication *app = [CubeApplication currentApplication];
        funDetialVC.delegate=self;
       
        if (_currentShowStatus==EAPPINSTALLED) {
            funDetialVC.curCubeModlue=[[[CubeApplication sortByCategroy:app.modules] objectForKey:[[self.curDic sortedAllkeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] ;
            funDetialVC.buttonStatus = InstallButtonStateInstalled;
        }else if(_currentShowStatus==EAPPUNINSTALLED) {
            funDetialVC.curCubeModlue=[[[CubeApplication sortByCategroy:app.availableModules] objectForKey:[[self.curDic sortedAllkeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] ;
            funDetialVC.buttonStatus = InstallButtonStateUninstall;
        }else{
            funDetialVC.curCubeModlue=[[[CubeApplication sortByCategroy:app.updatableModules] objectForKey:[[self.curDic sortedAllkeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            funDetialVC.buttonStatus = InstallButtonStateUpdatable;
        }
       isGoTODetailView = true;
        [self.navigationController pushViewController:funDetialVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRGBHex:0xFFFFFF];
    } else {
        cell.backgroundColor = [UIColor  colorWithRGBHex:0xf6f6f6];
    }
}


#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [super searchBarShouldBeginEditing:searchBar];
    self.contentTableView.scrollEnabled = NO;
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [super searchBarShouldEndEditing:searchBar];
    self.contentTableView.scrollEnabled = YES;
    return YES;
}

@end

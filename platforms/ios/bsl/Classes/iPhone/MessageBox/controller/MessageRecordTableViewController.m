//
//  MessageRecordTableViewController.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/1/13.
//
//

#import "MessageRecordTableViewController.h"
#import "CubeApplication.h"
#import "MessageRecordHeaderView.h"
#import "CubeModule.h"
#import "MessageRecord.h"
#import "MessageRecordTableViewCell.h"
#import "AnnouncementTableViewController.h"

#import "CubeWebViewController.h"
#import "MessageRecordCell.h"
#import "JSONKit.h"


@interface MessageRecordTableViewController ()<UITableViewDataSource,UITableViewDelegate,MessageRecordHeaderViewDelegate>{
    NSMutableDictionary *presentModulesDic;
    NSMutableDictionary *expandDic;
    NSMutableDictionary *flagDictionary;
    NSString *selectedModule;
    
}
-(void)delayLoadTimerEvent;

-(void)createRrightNavItem;
-(void)rightNavClick;

@end

@implementation MessageRecordTableViewController

- (id)init{
    self = [super init];
    if (self) {
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = YES;
         }
        self.title = @"消息推送";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageRevice:) name:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:nil];
        
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    CGRect rect=self.view.frame;
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        rect.size.width =CGRectGetHeight(self.view.frame)/2+2;
        rect.size.height= CGRectGetWidth(self.view.frame)-self.navigationController.navigationBar.bounds.size.height-44.0f;
    }
    else{
        rect.size.height-=44.0f;
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
        rect.size.height-=20.0f;
    }

    self.view.frame=rect;
    
    flagDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
    presentModulesDic = [[NSMutableDictionary alloc] init];
    
    expandDic = [[NSMutableDictionary alloc] init];
    
    tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    tableView.backgroundColor=[UIColor whiteColor];
    tableView.delegate=self;
    tableView.dataSource=self;
    
    
    UIView* v=[[UIView alloc] init];
    v.backgroundColor=[UIColor clearColor];
    tableView.tableFooterView=v;
    tableView.tableHeaderView=v;
    v=nil;
    
    [self.view addSubview:tableView];

    
    [self loadData];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    presentModulesDic=nil;
    expandDic=nil;
    flagDictionary=nil;
    selectedModule=nil;
}


-(void)viewWillAppear:(BOOL)animated{

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [tableView reloadData];
    
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        UIView* vv=[[UIView alloc] initWithFrame:CGRectMake(floor(0.0f), floor(0.0f), floor(self.view.frame.size.width), floor(44.0f))];
        
        UILabel*label = [[UILabel alloc]initWithFrame:CGRectMake(floor(-10.0f), floor(0.0f), floor(self.view.frame.size.width), floor(44.0f))];
        label.text = @"消息推送";
        label.font =[UIFont boldSystemFontOfSize:20];
        label.textColor= [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment =NSTextAlignmentCenter;
        [vv addSubview:label];
        self.navigationItem.titleView= vv;
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //这里的实现效率很差还会导致卡，更换FMDB后sql语句更新状态效率更高
    //TODO 待优化
    /*
    NSArray *systemRecords = [MessageRecord findSystemRecord];
    for(MessageRecord *record in systemRecords){
        record.isRead = [NSNumber numberWithBool:YES];
        //        [record save];
    }
    for(CubeModule *each in [[CubeApplication currentApplication]modules]){
        if (![each.identifier isEqualToString:@"com.foss.chat"]) {
            
            NSArray *records = [MessageRecord findForModuleIdentifier:each.identifier];
            if([records count] > 0 ){
                for (MessageRecord * rec in records) {
                    rec.isRead = [NSNumber numberWithBool:YES];
                    //                        [rec save];
                }
            }
        }
    }
    [MessageRecord save];
     */
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadData{
    
    NSArray *modules = [[CubeApplication currentApplication] modules];
    
    NSArray *systemRecords = [MessageRecord findSystemRecord];
    
    if(systemRecords && systemRecords.count > 0){
        [presentModulesDic setObject:systemRecords forKey:@"0system"];
    }
    //装入本地模块
    for(CubeModule *each in modules){
        if (![each.identifier isEqualToString:@"com.foss.chat"]) {
            if (each.local) {
                NSArray *records = [MessageRecord findForModuleIdentifier:each.identifier];
                if([records count] > 0 ){
                    [presentModulesDic setObject:records forKey:each.identifier];
                }
            }
        }
    }
    //再装入非本地模块
    for(CubeModule *each in modules){
        if (![each.identifier isEqualToString:@"com.foss.chat"]) {
            if (!each.local) {
                NSArray *records = [MessageRecord findForModuleIdentifier:each.identifier];
                
                if([records count] > 0 ){
                    [presentModulesDic setObject:records forKey:each.identifier];
                }
            }
            
        }
    }
    
    [self createRrightNavItem];

}

-(void)delayLoadTimerEvent{
    [delayLoadTimer invalidate];
    delayLoadTimer=nil;
    [self loadData];
    [tableView reloadData];
}

-(void)newMessageRevice:(NSNotification*)notification{
    [delayLoadTimer invalidate];
    delayLoadTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayLoadTimerEvent) userInfo:nil repeats:NO];
}

-(void)rightNavClick{
    //    tableView.editing=!tableView.editing;
    [tableView setEditing:!tableView.editing animated:YES];
    [self createRrightNavItem];
    
}

-(void)createRrightNavItem{
    if([presentModulesDic count]<1){
        self.navigationItem.rightBarButtonItem=nil;
        return;
    }
    UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
    //navRightButton.style = UIBarButtonItemStyleBordered;
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
    [navRightButton setTitle:(tableView.editing?@"取消":@"编辑") forState:UIControlStateNormal];
    [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
    [navRightButton addTarget:self action:@selector(rightNavClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__tableView{
    // Return the number of sections.
    return [[presentModulesDic allKeys] count];
}

- (NSInteger)tableView:(UITableView *)__tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    //[[self.expandDic objectForKey:moduleId] isEqualToNumber:[NSNumber numberWithBool:YES] ]
    
    if([[expandDic objectForKey:[NSNumber numberWithInteger:section]] isEqualToNumber:[NSNumber numberWithBool:YES]]){
        return [[presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:section]] count];
    }
    return 0;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)__tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    MessageRecordCell *cell = [__tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MessageRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    MessageRecord *messageRecord = [[presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [cell title:messageRecord.alert content:messageRecord.content time:messageRecord.reviceTime isRead:[messageRecord.isRead boolValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)__tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageRecord *messageRecord = [[presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    return [MessageRecordCell cellHeight:messageRecord.alert content:messageRecord.content width:__tableView.frame.size.width];
    
}

-(void)shouldShowCellInModule:(NSString *)moduleId atIndex:(NSInteger)section{
    
    [flagDictionary setValue:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",section]];
    int sectionIndex =  [[presentModulesDic  allKeys] indexOfObject:moduleId];
    if([[expandDic objectForKey:[NSNumber numberWithInteger:sectionIndex]] isEqualToNumber:[NSNumber numberWithBool:YES] ]){
        
        [expandDic setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInteger:sectionIndex]];
    }else{
    
        [expandDic setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:sectionIndex]];
    }

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UIView *)tableView:(UITableView *)__tableView viewForHeaderInSection:(NSInteger)section{
    
    MessageRecordHeaderView *headerView = [[MessageRecordHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 36)];
    headerView.delegate = self;
    headerView.section = section;
    
    CubeModule *module = [[CubeApplication currentApplication] moduleForIdentifier:[[presentModulesDic allKeys] objectAtIndex:section]];
    
    headerView.moduleId = module.identifier;
    
    int msgcount = 0;
    NSArray *array = [presentModulesDic objectForKey:[[presentModulesDic allKeys]objectAtIndex:section]];
    for(MessageRecord *msr in array){
//        if([flagDictionary valueForKey:[NSString stringWithFormat:@"%d",section]] != [NSNumber numberWithBool:YES])
        {
            if([msr.isRead intValue] == 0)
            {
                msgcount ++;
            }
        }
        
    }
    if(module){
        [headerView configureWithIconUrl:module.iconUrl moduleName:module.name messageCount:[NSString stringWithFormat:@"%d",[[presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:section]] count]] sectionIndenx:section withUnReadCount:[NSString stringWithFormat:@"%d",msgcount ]];
        
    }else{
        headerView.moduleId = @"0system";
        [headerView configureWithIconUrl:nil moduleName:@"系统" messageCount:[NSString stringWithFormat:@"%d",[[presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:section]] count]] sectionIndenx:section withUnReadCount:[NSString stringWithFormat:@"%d",msgcount ]];
        
    }
    
    headerView.tag = section + 10;
    
    
    UIImageView* arrowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xmpp_arrow.png"]];
    arrowImageView.frame= CGRectMake(17, 15, 10, 11);
    if([[expandDic objectForKey:[NSNumber numberWithInteger:section]] isEqualToNumber:[NSNumber numberWithBool:YES]]){
        arrowImageView.image  = [self imageTransform:arrowImageView.image rotation:UIImageOrientationRight];
    }
    [headerView addSubview:arrowImageView];

    return headerView;
}




- (UIImage *)imageTransform:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}


-(void)deleteModuleData:(NSString* )moduleIdendity{
    
    NSArray *moduleRecords = [presentModulesDic objectForKey:moduleIdendity];
   
    for ( int i = 0; i<  [moduleRecords count]; i++) {
        MessageRecord *record = [moduleRecords objectAtIndex:i];
        if (i+1 == [moduleRecords count]) {
            [record remove];
        }else{
            [record removeNoSave];
        }
    }
    
    [presentModulesDic removeObjectForKey:moduleIdendity];
    [self delayLoadTimerEvent];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"module_badgeCount_change" object:nil];

    
    //保存数据
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)__tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(__tableView.editing)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)__tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSMutableArray *moduleRecords = [presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]];
        NSArray *newModuleRecords = [MessageRecord findForModuleIdentifier:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]];
        //删除的是本地模块
        MessageRecord *record = [moduleRecords objectAtIndex:indexPath.row];
        [record remove];
        [MessageRecord save];
        
        if(newModuleRecords.count <1 ){
           [presentModulesDic setObject:[MessageRecord findSystemRecord] forKey:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]];
            
            if([moduleRecords count]<2){
                [expandDic setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInteger:[indexPath section]]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"module_badgeCount_change" object:nil];

            
        }else{
            [presentModulesDic setObject:newModuleRecords forKey:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]];
            
            MessageRecordHeaderView *headerView  = (MessageRecordHeaderView *)[__tableView viewWithTag:indexPath.section + 100];
            
            headerView.messageCountLabel.text = [NSString stringWithFormat:@"%d",[newModuleRecords count]];
        }
        
        [self delayLoadTimerEvent];
        //[__tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

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

- (void)tableView:(UITableView *)__tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [__tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    
    CubeModule *module = [[CubeApplication currentApplication] moduleForIdentifier:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]];
    MessageRecord *messageRecord = [[presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    if(![messageRecord.isRead boolValue]){
        messageRecord.isRead=[NSNumber numberWithBool:YES];
        messageRecord.isMessageBadge=[NSNumber numberWithInt:0];
        int isIconBadge=[messageRecord.isIconBadge intValue]-1;
        if(isIconBadge<0)isIconBadge=0;
        messageRecord.isIconBadge=[NSNumber numberWithInt:isIconBadge];
        [messageRecord save];
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"module_badgeCount_change" object:nil];
    }
    if(module.local  && ![module.identifier isEqualToString:@"com.foss.announcement"]){
        NSString* iphoneLocal;
        if ([module.local isEqualToString:@"DetailViewController"]) {
            iphoneLocal = @"iphoneVoiceMasterViewController";
        }else{
            iphoneLocal = module.local;
        }
        UIViewController *localController = (UIViewController *)[[NSClassFromString(iphoneLocal) alloc] init];
        
        [self.navigationController.navigationBar setHidden:NO ];
        [self.navigationController pushViewController:localController animated:YES];
        
        
        return;
    }
    else if(module.local  && [module.identifier isEqualToString:@"com.foss.announcement"])
    {
//        NSString* iphoneLocal = module.local;
        
        AnnouncementTableViewController *localController = (AnnouncementTableViewController *)[[NSClassFromString(@"AnnouncementTableViewController") alloc] init];
        NSString *recordId = messageRecord.recordId;
        localController.recordId = recordId;
        [self.navigationController.navigationBar setHidden:NO ];
        [self.navigationController pushViewController:localController animated:YES];
        
        return;
    }
    
    
    
    //判断不是本地模块
    if ([messageRecord.allContent  boolValue] ) {
        @autoreleasepool {
            NSDictionary *missingModules = [module missingDependencies];
            NSArray *needInstall = [missingModules objectForKey:kMissingDependencyNeedInstallKey];
            NSArray *needUpgrade = [missingModules objectForKey:kMissingDependencyNeedUpgradeKey];
            
            if ([needInstall count] > 0 || [needUpgrade count] > 0) {
                NSMutableString *message = [[NSMutableString alloc] init];
                
                if([needInstall count] > 0){
                    
                    [message appendString:@"需要安装以下模块:\n"];
                    for ( NSString *dependency in needInstall) {
                        CubeModule *m = [[CubeApplication currentApplication] availableModuleForIdentifier:dependency];
                        if(m!=nil)
                            [message appendFormat:@"%@(build:%d)\n", m.name,m.build];
                        else
                            [message appendFormat:@"%@\n", dependency];
                    }
                    
                }
                
                if( [needUpgrade count] > 0){
                    
                    [message appendString:@"需要升级以下模块:\n"];
                    for ( NSString *dependency in needUpgrade) {
                        CubeModule *m = [[CubeApplication currentApplication] moduleForIdentifier:dependency];
                        if(m!=nil)
                            [message appendFormat:@"%@(build:%d)\n", m.name,m.build];
                        else
                            [message appendFormat:@"%@\n", dependency];
                    }
                    
                }
                
                selectedModule = module.identifier;
                UIAlertView *dependsAlert = [[UIAlertView alloc] initWithTitle:@"缺少依赖模块"
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:@"确定" otherButtonTitles:/*@"安装", */nil];
                [dependsAlert show];
                return;
            }
        }
        
        //植入界面
        if (!cubeWebViewController) {
            cubeWebViewController  = [[CubeWebViewController alloc] init];
        }
        cubeWebViewController.title=module.name;
        
        MessageRecord *messageRecord = [[presentModulesDic objectForKey:[[presentModulesDic allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        
        NSString * moduleIndex = [[[module runtimeURL] URLByAppendingPathComponent:@"index.html"] absoluteString];
        
//        if(!messageRecord.recordId || messageRecord.recordId.length == 0 ){
//            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"旧数据不支持跳转" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alertView show];
//            return;
//        }
//        
        cubeWebViewController.startPage = [NSString stringWithFormat:@"%@?recordId=%@", moduleIndex, messageRecord.recordId];
        
        [cubeWebViewController loadWebPageWithModuleIdentifier:module.identifier didFinishBlock: ^(){
            NSLog(@"finish loading");
            [self.navigationController.navigationBar setHidden:NO];
            
            [self.navigationController pushViewController:cubeWebViewController animated:YES];
            
            
            cubeWebViewController = nil;
        }   didErrorBlock:^(){
            NSLog(@"error loading");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"消息模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            cubeWebViewController = nil;
        }];
    }
    
    

}

//修改删除按钮的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        CubeModule *module = [[CubeApplication currentApplication] moduleForIdentifier:selectedModule];
        //需要下载的模块
        NSArray *missingModules = [[module missingDependencies] objectForKey:kMissingDependencyNeedInstallKey];
        for (NSString *missingModule in missingModules) {
            CubeModule *am = [[CubeApplication currentApplication] availableModuleForIdentifier:missingModule];
            am.isDownloading = YES;
            [[CubeApplication currentApplication] installModule:am];
        }
        
        //需要升级的模块
        NSArray *needUpgradeModules = [[module missingDependencies] objectForKey:kMissingDependencyNeedUpgradeKey];
        for (NSString *needUpgradeModule in needUpgradeModules) {
            CubeModule *am = [[CubeApplication currentApplication] updatableModuleModuleForIdentifier:needUpgradeModule];
            am.isDownloading = YES;
            [[CubeApplication currentApplication] installModule:am];
        }
    }
}



@end

//
//  FriendMainViewController.m
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import "FriendMainViewController.h"
#import "HeadTabView.h"
#import "RecentTalkView.h"
#import "ContactListView.h"
#import "FaviorContactView.h"
#import "ChatMainViewController.h"
#import "ContactSelectedForGroupViewController.h"
#import "SVProgressHUD.h"
#import "RectangleChat.h"
#import "ChatLogic.h"
#import "NumberView.h"
#import "IMServerAPI.h"
@interface FriendMainViewController ()<ContactListViewDelegate,HeadTabViewDelegte,RecentTalkViewDelegate,FaviorContactViewDelegate,UIPopoverControllerDelegate,ContactSelectedForGroupViewControllerDelegate,NSFetchedResultsControllerDelegate>
-(void)initTabBar;
-(void)filterClick;
-(void)openOrCreateListView:(int)tab;
-(void)addGroupChatClick;
-(void)createRrightNavItem;
-(void)loadNumber;
@property(nonatomic,strong) UISearchBar*  selectedSearchBar;

@end

@implementation FriendMainViewController
@synthesize selectedSearchBar;

-(id)init{
    self=[super init];
    if(self){
        self.title=@"即时通讯";
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        NSManagedObjectContext* managedObjectContext = [ShareAppDelegate xmpp].managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RectangleChat" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        //排序
        NSSortDescriptor*sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"updateDate"ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        [fetchedResultsController performFetch:&error];
        
        
    }
    
    
    return  self;
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
    [self initTabBar];
    
    
    tableViewHeight=self.view.frame.size.height-CGRectGetMaxY(tabView.frame);

    
    [self openOrCreateListView:1];
    
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        UIView* vv=[[UIView alloc] initWithFrame:CGRectMake(floor(0.0f), floor(0.0f), floor(self.view.frame.size.width), floor(44.0f))];
        
        UILabel*label = [[UILabel alloc]initWithFrame:CGRectMake(floor(-10.0f), floor(0.0f), floor(self.view.frame.size.width), floor(44.0f))];
        label.text = self.title;
        label.font =[UIFont boldSystemFontOfSize:20];
        label.textColor= [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment =NSTextAlignmentCenter;
        [vv addSubview:label];
        self.navigationItem.titleView= vv;
    }
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    if(tabView.selectedIndex==0){
        
    }
    else if(tabView.selectedIndex==1){
        [contactListView loadData];
    }
    else{
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
        [self setNeedsStatusBarAppearanceUpdate];
    }

}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [contactListView clear];
    contactListView=nil;
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    
    [contactListView clear];

    fetchedResultsController.delegate=nil;
    
    self.selectedSearchBar=nil;
    popover.delegate=nil;
    [popover dismissPopoverAnimated:NO];

}

#pragma mark method


-(void)createRrightNavItem{
        UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
        //navRightButton.style = UIBarButtonItemStyleBordered;
        [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
        [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
        if(tabView.selectedIndex==2){
            [navRightButton setTitle:(faviorContactView.editing?@"取消":@"编辑") forState:UIControlStateNormal];
        }
        else if(tabView.selectedIndex==0){
            [navRightButton setTitle:(recentTalkView.editing?@"取消":@"编辑") forState:UIControlStateNormal];

        }
        else{
            [navRightButton setTitle:@"群聊" forState:UIControlStateNormal];
            
        }
        [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
        [navRightButton addTarget:self action:@selector(addGroupChatClick) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
}

-(void)initTabBar{
    tabView=[[HeadTabView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.0f)];
    tabView.delegate=self;
    [self.view addSubview:tabView];
    
    [tabView setTabNameArray:[NSArray arrayWithObjects:@"最近聊天",@"好友列表",@"好友收藏", nil]];
    tabView.selectedIndex=1;
    
    numberView=[[NumberView alloc] init];
    [tabView addSubview:numberView];
    
    CGRect rect=numberView.frame;
    rect.origin.x=tabView.frame.size.width/3.0f-rect.size.width-20.0f;
    numberView.frame=rect;
    
    [self loadNumber];

}

-(void)openOrCreateListView:(int)tab{
    recentTalkView.hidden=YES;
    contactListView.hidden=YES;
    faviorContactView.hidden=YES;
    [self filterClick];

    if(tab==0){
        if(recentTalkView==nil){
            recentTalkView=[[RecentTalkView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(tabView.frame), self.view.frame.size.width, tableViewHeight) style:UITableViewStylePlain];
            recentTalkView.rectentDelegate=self;
            [self.view addSubview:recentTalkView];
        }
        recentTalkView.hidden=NO;
        
    }
    else if(tab==1){
        if(contactListView==nil){
            
            contactListView=[[ContactListView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(tabView.frame), self.view.frame.size.width, tableViewHeight)];
            contactListView.delegate=self;
            [self.view addSubview:contactListView];
            
        }
        contactListView.hidden=NO;
        [contactListView loadData];
    }
    else if(tab==2){
        if(faviorContactView==nil){
            faviorContactView=[[FaviorContactView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(tabView.frame), self.view.frame.size.width, tableViewHeight) style:UITableViewStylePlain];
            faviorContactView.faviorDelegate=self;
            [self.view addSubview:faviorContactView];
        }
        faviorContactView.hidden=NO;
    }
    if(tab!=0){
        [recentTalkView setEditing:NO animated:NO];
    }
    else if(tab!=2){
        [faviorContactView setEditing:NO animated:NO];
    }
    [self createRrightNavItem];

}

-(void)filterClick{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.selectedSearchBar setShowsCancelButton:NO animated:YES];
    [self.selectedSearchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        fliterBg.alpha=0.0f;
    } completion:^(BOOL finish){
        [fliterBg removeFromSuperview];
        fliterBg=nil;
        [self.selectedSearchBar resignFirstResponder];
        self.selectedSearchBar=nil;
    }];
}

-(void)addGroupChatClick{
    
    if(tabView.selectedIndex==2){
        
        [faviorContactView setEditing:!faviorContactView.editing animated:YES];
        [self createRrightNavItem];
        return;
    }
    else if(tabView.selectedIndex==0){
        [recentTalkView setEditing:!recentTalkView.editing animated:YES];
        [self createRrightNavItem];
        return;

    }
    
    AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate xmpp] isConnected]) {
        [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        return;
    }

    ContactSelectedForGroupViewController* controller=[[ContactSelectedForGroupViewController alloc] init];
    controller.dicts=[contactListView friendsList];
    controller.delegate=self;
    
    
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        popover.delegate=nil;
        [popover dismissPopoverAnimated:NO];
        popover=nil;
        popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        popover.delegate=self;        
        popover.popoverContentSize=self.view.frame.size;
        [popover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    }
    else{
        
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        
    }
    
}

-(void)loadNumber{
    int number=0;
    NSArray *contentArray = [fetchedResultsController fetchedObjects];
    
    for(RectangleChat* obj in contentArray){
        number+=[obj.noReadMsgNumber intValue];
    }
    

    [numberView number:number];
}

#pragma mark contactselectedby group delegate

-(void)dismiss:(ContactSelectedForGroupViewController *)controller selectedInfo:(NSArray *)selectedInfo{
    if(selectedInfo!=nil){
        [self openOrCreateListView:0];
        ChatMainViewController* __controller=[[ChatMainViewController alloc] init];
        __controller.messageId=controller.tempNewjid;
        __controller.chatName=controller.groupName;
        
        __controller.isGroupChat=YES;
        [self.navigationController pushViewController:__controller animated:YES];

    }
    if(popover!=nil){
        popover.delegate=nil;
        [popover dismissPopoverAnimated:YES];
        popover=nil;
    }
    else{
        [controller dismissViewControllerAnimated:YES completion:^{}];
    }
}

#pragma mark imagepicker delegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    popover.delegate=nil;
    [popover dismissPopoverAnimated:NO];
    popover=nil;
    return YES;
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    popover.delegate=nil;
    [popover dismissPopoverAnimated:NO];
    popover=nil;
    
}


#pragma mark  headtab delegate

-(void)tabDidSelected:(HeadTabView*)tabView index:(int)index{
    [self openOrCreateListView:index];
}

#pragma mark contactlist delegate

-(void)contactListDidTouch:(ContactListView*)contactList{
    [self filterClick];
}

-(void)contactListDidSearchShouldBeginEditing:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar{
    self.selectedSearchBar=searchBar;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.selectedSearchBar setShowsCancelButton:YES animated:YES];
    if(fliterBg==nil){
        fliterBg=[UIButton buttonWithType:UIButtonTypeCustom];
        [fliterBg addTarget:self action:@selector(filterClick) forControlEvents:UIControlEventTouchUpInside];
        fliterBg.backgroundColor=[UIColor blackColor];
        fliterBg.frame=CGRectMake(0.0f, tabView.frame.size.height+self.selectedSearchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:fliterBg];
    }
    fliterBg.alpha=0.0f;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        fliterBg.alpha=0.6f;
    } completion:^(BOOL finish){
    }];
}

-(void)contactListSearchBarSearchButtonClicked:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar{
    [self filterClick];

}

-(void)contactListSearchBarCancelButtonClicked:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar{
    [self filterClick];

}

-(void)contactListSearchBarTextChanged:(ContactListView*)contactList searchBar:(UISearchBar*)searchBar{
    NSString* searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    fliterBg.hidden=([searchText length]>0);

}



-(void)contactListDidSelected:(ContactListView*)contactList userInfo:(UserInfo*)userInfo{
    AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate xmpp] isConnected]) {
        [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        return;
    }

    ChatMainViewController* controller=[[ChatMainViewController alloc] init];
    controller.messageId=userInfo.userJid;
    controller.chatName=[userInfo name];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark rectangle talk delegate

-(void)rectentTalkViewDidSelected:(RecentTalkView *)recentTalkView rectangleChat:(RectangleChat *)rectangleChat{
    AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate xmpp] isConnected]) {
        [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        return;
    }
    ChatMainViewController* controller=[[ChatMainViewController alloc] init];
    controller.messageId=rectangleChat.receiverJid;
    controller.chatName=rectangleChat.name;
    controller.isQuit=[rectangleChat.isQuit boolValue];
    controller.isGroupChat=[rectangleChat.isGroup boolValue];
    [self.navigationController pushViewController:controller animated:YES];

}

#pragma mark favior view delegate

-(void)faviorContactViewDidSelected:(FaviorContactView *)recentTalkView userInfo:(UserInfo *)userInfo{
    AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate xmpp] isConnected]) {
        [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        return;
    }
    
    
    
    ChatMainViewController* controller=[[ChatMainViewController alloc] init];
    controller.messageId=userInfo.userJid;
    controller.chatName=[userInfo name];
    
    [self.navigationController pushViewController:controller animated:YES];

}

-(void)faviorContactViewDidDelete:(FaviorContactView*)recentTalkView userInfo:(UserInfo*)userInfo{
    
    [SVProgressHUD showWithStatus:@"操作执行中..." maskType:SVProgressHUDMaskTypeBlack];
    
    [IMServerAPI deleteCollectIMFriend:userInfo.userJid block:^(BOOL status){
            
        if(!status){
            [SVProgressHUD showErrorWithStatus:@"操作失败，请稍后再试！"];
        }
        else{
            ChatLogic* logic=[[ChatLogic alloc] init];
            [logic removeFaviorInContacts:userInfo.userJid];
            logic=nil;
            [SVProgressHUD showSuccessWithStatus:@"你已取消关注该好友"];
        }
    }];
    
}

#pragma mark  fetchedresultscontroller  delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{

    [self loadNumber];
}
@end

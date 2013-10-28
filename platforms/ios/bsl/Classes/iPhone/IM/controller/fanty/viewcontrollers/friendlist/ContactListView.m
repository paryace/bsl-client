//
//  ContactListView.m
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import "ContactListView.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "SVProgressHUD.h"
#import "TouchScroller.h"
#import "ContactCell.h"


@interface ContactListView()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate,TouchScrollerDelegate>{
    
    UISearchBar* searchBar;
    TouchTableView* tableView;
    NSTimer* friendListTimeOut;

    NSMutableArray* friendGroups;
    NSArray* friendList;
    NSString* selectedGroup;
}
-(void)friendsUpdate;
-(void)friendsUpdateProcess;
-(void)friendsUpdateAlone;
-(void)loadFriendsGroup;
-(void)loadFriends;
-(void)headerClick:(UIButton*)button;
-(void)friendListTimeOutEvent;
@end

@implementation ContactListView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled=YES;
        friendGroups=[[NSMutableArray alloc] initWithCapacity:2];
        searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 44.0f)];
        
        [self loadFriendsGroup];
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            searchBar.tintColor=[UIColor grayColor];
        }
        else{
            searchBar.barStyle=UIBarStyleBlackTranslucent;
        }
        searchBar.placeholder=@"输入关键字搜索";
        searchBar.delegate=self;
        [self addSubview:searchBar];
        
        tableView=[[TouchTableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(searchBar.frame), frame.size.width, frame.size.height-CGRectGetMaxY(searchBar.frame)) style:UITableViewStylePlain];
        tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        tableView.dataSource=self;
        tableView.delegate=self;
        tableView.touchDelegate=self;
        [self addSubview:tableView];

        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(friendsUpdate) name:kNOTIFICATION_UPDATE_FRIENDSFINISH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(friendsUpdateProcess) name:kNOTIFICATION_UPDATE_FRIENDSPROCESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(friendsUpdateAlone) name:kNOTIFICATION_UPDATE_FRIENDS object:nil];

    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [friendListTimeOut invalidate];
    
}

-(void)clear{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [friendListTimeOut invalidate];
    friendListTimeOut=nil;
}

-(void)syncFriends{
    if(friendListTimeOut!=nil || [ShareAppDelegate xmpp].friendListIsFinded!=XMPPFriendsStatusNone)return;
//    if([friendGroups count]<1){
        if ([[ShareAppDelegate xmpp] isConnected]) {
            [[ShareAppDelegate xmpp] findFriendsList];
            [SVProgressHUD showWithStatus:@"正在获取好友列表..."];
            
            [friendListTimeOut invalidate];
            friendListTimeOut=[NSTimer scheduledTimerWithTimeInterval:8.0f target:self selector:@selector(friendListTimeOutEvent) userInfo:nil repeats:NO];
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        }
        
//    }
}

-(void)friendListTimeOutEvent{
    [friendListTimeOut invalidate];
    friendListTimeOut=nil;
    if(self.superview!=nil)
        [SVProgressHUD showErrorWithStatus:@"即时通讯连接超时！"];
}


-(void)friendsUpdateProcess{
    [friendListTimeOut invalidate];
    friendListTimeOut=[NSTimer scheduledTimerWithTimeInterval:8.0f target:self selector:@selector(friendListTimeOutEvent) userInfo:nil repeats:NO];

}

-(void)loadFriendsGroup{
    NSString* searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [friendGroups removeAllObjects];
    if([searchText length]<1){
        NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
        [fetchRequest setPredicate:predicate];
        
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:[ShareAppDelegate xmpp].managedObjectContext];
        NSDictionary *properties = [entity propertiesByName];
        fetchRequest.entity=entity;
        fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[properties objectForKey:@"userGroup"]];
        fetchRequest.returnsDistinctResults=YES;
        fetchRequest.resultType = NSDictionaryResultType;
        //排序
        NSArray* groups = [[ShareAppDelegate xmpp].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        for(NSDictionary * dict in groups){
//            NSString* group=NSLocalizedString(userInfo.userGroup,nil);
            NSString* group=[dict objectForKey:@"userGroup"];
            [friendGroups addObject:group];
        }
    }
    else{
        [friendGroups addObject:@"搜索结果"];
    }
}

-(void)loadFriends{
    NSString* searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    friendList=nil;
    if([searchText length]<1){
        if([selectedGroup length]>0){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userGroup==%@",selectedGroup];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
            [fetchRequest setPredicate:predicate];
            //排序
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"userStatue" ascending:NO];
            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"userName" ascending:NO];
            NSArray *sortDescriptors = @[sortDescriptor1,sortDescriptor2];
            [fetchRequest setSortDescriptors:sortDescriptors];
            friendList = [[ShareAppDelegate xmpp].managedObjectContext executeFetchRequest:fetchRequest error:nil];

        }
    }
    else{
        searchText=[searchText lowercaseString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userJid CONTAINS %@ or userName CONTAINS %@",searchText,searchText];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
        [fetchRequest setPredicate:predicate];
        //排序
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"userStatue" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"userName" ascending:NO];
        NSArray *sortDescriptors = @[sortDescriptor1,sortDescriptor2];
        [fetchRequest setSortDescriptors:sortDescriptors];
        friendList = [[ShareAppDelegate xmpp].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    }

}

-(void)friendsUpdate{
    [friendListTimeOut invalidate];
    friendListTimeOut=nil;
    
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    
    [self loadFriendsGroup];
    [self loadFriends];
    [tableView reloadData];

}

-(void)friendsUpdateAlone{
    [self loadFriendsGroup];
    [self loadFriends];
    [tableView reloadData];

}

- (UIImage *)imageTransform:(UIImage *)image rotation:(UIImageOrientation)orientation{
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

-(void)headerClick:(UIButton*)button{
    NSString* groupName=[friendGroups objectAtIndex:button.tag];
    if([groupName isEqualToString:selectedGroup]){
        selectedGroup=nil;
    }
    else{
        selectedGroup=groupName;
    }
    [self loadFriends];
    [tableView reloadData];
}

#pragma mark  tableview delegate

- (void)tableView:(UIScrollView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event{
    [searchBar resignFirstResponder];
    if([self.delegate respondsToSelector:@selector(contactListDidTouch:)])
        [self.delegate contactListDidTouch:self];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [searchBar resignFirstResponder];
    if([self.delegate respondsToSelector:@selector(contactListDidTouch:)])
        [self.delegate contactListDidTouch:self];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  [friendGroups count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString* searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* groupName=[friendGroups objectAtIndex:section];

    if([searchText length]<1){
        UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(0.0f, 0.0f, self.frame.size.width, 40.0f);
        button.tag=section;
        [button addTarget:self action:@selector(headerClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"table_header.png"] forState:UIControlStateNormal];
        
        UIImageView* arrowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xmpp_arrow.png"]];
        CGRect rect=arrowImageView.frame;
        rect.size.width=13.0f;
        rect.size.height=13.0f;
        rect.origin.x=10.0f;
        rect.origin.y=(button.frame.size.height-rect.size.height)*0.5f-6.0f;
        arrowImageView.frame= rect;
        [button addSubview:arrowImageView];
        if ([groupName isEqualToString:selectedGroup]) {
            arrowImageView.image  = [self imageTransform:arrowImageView.image rotation:UIImageOrientationRight];
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(arrowImageView.frame)+10.0f, 0, button.frame.size.width-CGRectGetMaxX(arrowImageView.frame)-10.0f, 24.0f)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.shadowColor=[UIColor blackColor];
        titleLabel.shadowOffset=CGSizeMake(0.0f, 0.5f);
        titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text=NSLocalizedString(groupName,nil);
        [button addSubview:titleLabel];
        titleLabel=nil;
        return button;
    }
    else{
        UIImageView* view =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 40.0f)];
        view.image=[UIImage imageNamed:@"table_header.png"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, view.frame.size.width-20.0f, 24.0f)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.shadowColor=[UIColor blackColor];
        titleLabel.shadowOffset=CGSizeMake(0.0f, 0.5f);
        titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text=groupName;
        [view addSubview:titleLabel];
        titleLabel=nil;
        return view;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ContactCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSString* searchText=[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString* groupName=[friendGroups objectAtIndex:section];


    if(([searchText length]<1 && [groupName isEqualToString:selectedGroup]) || [searchText length]>0)
        return [friendList count];
    
    return 0.0f;
}

-(UITableViewCell*)tableView:(UITableView *)__tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactCell *cell = (ContactCell*)[__tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] ;
    }
    UserInfo* user=[friendList objectAtIndex:[indexPath row]];
    [cell headerUrl:@"" nickname:[user name]];
    
    if ([user.userSex isEqualToString:@"female"]) {
        if ([user.userStatue length] > 0 ) {
            [cell loadingImage:@"chatroom_female_online.jpg"];
        }else{
            [cell loadingImage:@"chatroom_female_outline.jpg"];
        }
        
    }else if([user.userSex isEqualToString:@"male"]){
        if ([user.userStatue length] > 0 ) {
            [cell loadingImage:@"chatroom_male_online.jpg"];

        }else{
            [cell loadingImage:@"chatroom_male_outline.jpg"];

        }
    }else{
        if ([user.userStatue length] > 0 ) {
            [cell loadingImage:@"chatroom_unknow_online.jpg"];
        }
        else{
            [cell loadingImage:@"NoHeaderImge.png"];
        }
    }

    
    
    return cell;

}

-(void)tableView:(UITableView *)__tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [__tableView deselectRowAtIndexPath:indexPath animated:YES];
    [searchBar resignFirstResponder];

    
    UserInfo* user=[friendList objectAtIndex:[indexPath row]];
    if([self.delegate respondsToSelector:@selector(contactListDidSelected:userInfo:)])
        [self.delegate contactListDidSelected:self userInfo:user];
}


#pragma mark searchbar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)_searchBar{
    //  [searchBar setShowsCancelButton:YES animated:YES];
    
    if([self.delegate respondsToSelector:@selector(contactListDidSearchShouldBeginEditing:searchBar:)])
        [self.delegate contactListDidSearchShouldBeginEditing:self searchBar:searchBar];
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)__searchBar{
    for(id cc in [__searchBar subviews]){
        if([cc isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
    }
}

- (void)searchBar:(UISearchBar *)__searchBar textDidChange:(NSString *)searchText{
    
    if([self.delegate respondsToSelector:@selector(contactListSearchBarTextChanged:searchBar:)])
        [self.delegate contactListSearchBarTextChanged:self searchBar:searchBar];


    [self loadFriendsGroup];
    [self loadFriends];
    [tableView reloadData];

    [searchBar becomeFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar{
    if([self.delegate respondsToSelector:@selector(contactListSearchBarSearchButtonClicked:searchBar:)])
        [self.delegate contactListSearchBarSearchButtonClicked:self searchBar:searchBar];

}
- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar{
    searchBar.text=nil;

    [self loadFriendsGroup];
    [self loadFriends];
    [tableView reloadData];

    
    if([self.delegate respondsToSelector:@selector(contactListSearchBarCancelButtonClicked:searchBar:)])
        [self.delegate contactListSearchBarCancelButtonClicked:self searchBar:searchBar];
}


@end

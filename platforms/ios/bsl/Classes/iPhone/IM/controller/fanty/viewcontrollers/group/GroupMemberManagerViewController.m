//
//  GroupMemberManagerViewController.m
//  cube-ios
//
//  Created by 肖昶 on 13-9-18.
//
//

#import "GroupMemberManagerViewController.h"
#import "GroupPanel.h"
#import "GroupRoomUserEntity.h"
#import "ContactSelectedForGroupViewController.h"
#import "ChatLogic.h"
#import "RoomService.h"
#import "SVProgressHUD.h"
#import "IMServerAPI.h"
#import "HTTPRequest.h"

@interface GroupMemberManagerViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,GroupPanelDelegate,UIPopoverControllerDelegate,ContactSelectedForGroupViewControllerDelegate>
-(void)loadData;
-(void)initGroupPanel;
-(void)initQuitButton;
-(void)quitClick;
-(void)delaySendRemoveRoom;
@end

@implementation GroupMemberManagerViewController
@synthesize delegate;
@synthesize isQuit;
-(id)init{
    self=[super init];
    if(self){
        self.title=@"群组管理";
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = YES;
        }

    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ChatBackground_00.jpg"]];

    CGRect rect=self.view.frame;
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        rect.size.width =CGRectGetHeight(self.view.frame)/2+2;
        rect.size.height= CGRectGetWidth(self.view.frame)-self.navigationController.navigationBar.bounds.size.height;
    }
    else{
        rect.size.height-=44.0f;
    }
    self.view.frame=rect;

    [self loadData];
    
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        UIView* vv=[[UIView alloc] initWithFrame:CGRectMake(floor(0.0f), floor(0.0f), floor(self.view.frame.size.width), floor(44.0f))];
        
        UILabel*label = [[UILabel alloc]initWithFrame:CGRectMake(floor(-80.0f), floor(0.0f), floor(self.view.frame.size.width), floor(44.0f))];
        label.text = self.title;
        label.font =[UIFont boldSystemFontOfSize:20];
        label.textColor= [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment =NSTextAlignmentCenter;
        [vv addSubview:label];
        self.navigationItem.titleView= vv;
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [request cancel];
    request=nil;
    list=nil;
    tableView=nil;
    groupPanel=nil;
    quitButton=nil;
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [request cancel];
    tableView=nil;
    groupPanel=nil;
    quitButton=nil;
    popover.delegate=nil;
    [popover dismissPopoverAnimated:NO];

    self.messageId=nil;
    self.chatName=nil;
}

#pragma method

-(void)loadData{
    [request cancel];
    [SVProgressHUD showWithStatus:@"正在获取成员列表..."];
    request=[IMServerAPI grouptGetMembers:self.messageId block:^(BOOL status,NSArray* array){
        
        request=nil;
        list=nil;
        if(status){
            [SVProgressHUD dismiss];
            list=[[NSMutableArray alloc] initWithArray:array];
            
            tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
            tableView.backgroundColor=[UIColor clearColor];
            tableView.delegate=self;
            tableView.dataSource=self;
            [self.view addSubview:tableView];
            
        }
        else{
            UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"获取成员失败，请检查网络！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            alertView=nil;
        }
        
        
    }];
}


-(void)initGroupPanel{
    if(groupPanel==nil){
        float offset=10.0f;
        if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad)
            offset=25.0f;
            
        groupPanel=[[GroupPanel alloc] initWithFrame:CGRectMake(offset, 0.0f, tableView.frame.size.width-offset*2.0f, 0.0f)];
        groupPanel.delegate=self;
        [groupPanel setArray:list];

    }
    if(self.isQuit){
        [groupPanel hideAddButton];
        [groupPanel hideRemoveButtons];
    }
    if(!isMyGroup){
        [groupPanel hideRemoveButtons];
    }
    
}

-(void)initQuitButton{
    if(quitButton==nil){
        quitButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [quitButton addTarget:self action:@selector(quitClick) forControlEvents:UIControlEventTouchUpInside];
        UIImage* img=[UIImage imageNamed:@"btn_red.png"];
        [quitButton setBackgroundImage:[img stretchableImageWithLeftCapWidth:img.size.width*0.5f topCapHeight:img.size.height*0.5f] forState:UIControlStateNormal];
        
        @autoreleasepool {
            XMPPIMActor* xmpp=[ShareAppDelegate xmpp];
            
            RectangleChat* rectChat=[xmpp fetchRectangleChatFromJid:self.messageId isGroup:self.isGroupChat];
            //rectChat==nil  是好愚蠢的做法， 原因的处理是刚建立群组，直接进入管理，就会发现其为空， 要找找原因才行
            if(rectChat==nil || [rectChat.createrJid isEqualToString:[xmpp.xmppStream.myJID bare]]){
                isMyGroup=YES;
                [quitButton setTitle:@"解散退出群组" forState:UIControlStateNormal];
            }
            else{
                [quitButton setTitle:@"退出群组" forState:UIControlStateNormal];
                
            }
        }
        
        
        
        float offset=10.0f;
        if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad)
            offset=25.0f;

        quitButton.frame=CGRectMake(offset, 0.0f, tableView.frame.size.width-offset*2.0f, 44.0f);
    }
    
    quitButton.hidden=self.isQuit;
}


-(void)quitClick{
    UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"你确定要退出该群组吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag=332211;
    [alertView show];
    
}

#pragma mark table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        [self initGroupPanel];
        return groupPanel.frame.size.height+20.0f;
    }
    else if([indexPath section]==1){
    }
    else if([indexPath section]==2){
        [self initQuitButton];        
    }

    return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0)
        cell.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
    else if([indexPath section]==2){
        cell.backgroundColor=[UIColor clearColor];
        cell.backgroundView=nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cellName=@"cell";
    if([indexPath section]==1)
        cellName=@"cell1";
    else if([indexPath section]==2)
        cellName=@"cell2";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName] ;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    
    if([indexPath section]==0){
        [self initGroupPanel];
        [cell addSubview:groupPanel];
    }
    else if([indexPath section]==1){
        cell.textLabel.text=[NSString stringWithFormat:@"群组名：%@",self.chatName];
    }
    else if([indexPath section]==2){
        [self initQuitButton];
        [cell addSubview:quitButton];
    }
    
    cell.accessoryType=([indexPath section]==1?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone);
    cell.selectionStyle=([indexPath section]==1?UITableViewCellSelectionStyleBlue:UITableViewCellSelectionStyleNone);

    return cell;
    
}

-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if([indexPath section]==1 && !self.isQuit && isMyGroup){
        
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"修改群组名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle=UIAlertViewStylePlainTextInput;
        [alert show];
        alert=nil;
    }
}

#pragma mark alertview delegate

-(void)delaySendRemoveRoom{
    [[ShareAppDelegate xmpp].roomService removeNewRoom:self.messageId destory:isMyGroup];
}

-(void)quitGroupAction:(BOOL)status{
    request=nil;

    if(!status){
        UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"操作失败，请检查网络！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        alertView=nil;

        return ;
    }
    [SVProgressHUD dismiss];
    
    XMPPIMActor* xmpp=[ShareAppDelegate xmpp];
    ChatLogic* logic=[[ChatLogic alloc] init];
    logic.roomJID=self.messageId;
    [logic sendNotificationMessage:@"你已退出群组" messageId:self.messageId isGroup:self.isGroupChat name:nil onlyUpdateChat:YES];
    
    RectangleChat* rectangleChat=[xmpp fetchRectangleChatFromJid:self.messageId isGroup:self.isGroupChat];
    if(rectangleChat!=nil){
        rectangleChat.isQuit=[NSNumber numberWithBool:YES];
        rectangleChat.content=@"你已退出群组";
        rectangleChat.contentType=[NSNumber numberWithInt:RectangleChatContentTypeMessage];
//        [rectangleChat didSave];
    }
    [xmpp saveContext];
    
    [logic sendRoomQuitAction:self.messageId isMyGroup:isMyGroup];
    
    logic=nil;

    [self performSelector:@selector(delaySendRemoveRoom) withObject:nil afterDelay:2.0f];
    
    if([self.delegate respondsToSelector:@selector(deleteMember:)])
        [self.delegate deleteMember:self];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        if(alertView.tag==332211){
            
            [request cancel];
            [SVProgressHUD showWithStatus:@"正在执行退出..." maskType:SVProgressHUDMaskTypeBlack];
            
            if(!isMyGroup){
                request=[IMServerAPI grouptDeleteMember:[[ShareAppDelegate xmpp].xmppStream.myJID bare] roomId:self.messageId block:^(BOOL status){
                    [self quitGroupAction:status];
                }];
            }
            else{
                request=[IMServerAPI grouptDeleteRoom:self.messageId block:^(BOOL status){
                    [self quitGroupAction:status];
                }];
            }
        }
        else if(alertView.tag==778899){
            
            [SVProgressHUD showWithStatus:@"正在执行操作..." maskType:SVProgressHUDMaskTypeBlack];

            
            request=[IMServerAPI grouptDeleteMember:groupPanel.selectedJid roomId:self.messageId block:^(BOOL status){
                
                request=nil;
                if(!status){
                    UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"操作失败，请检查网络！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    alertView=nil;
                    
                    return ;
                }
                [SVProgressHUD dismiss];
                ChatLogic* logic=[[ChatLogic alloc] init];
                logic.roomJID=self.messageId;
                [logic sendRoomQuitMemberAction:self.messageId userJid:groupPanel.selectedJid];

                [groupPanel removeUserJid:groupPanel.selectedJid];
                logic=nil;
                

            }];
            
        }
        else{
            UITextField* textField=[alertView textFieldAtIndex:0];
            if([textField.text length]>0){
                self.chatName=textField.text;
                [request cancel];
                [SVProgressHUD showWithStatus:@"操作执行中..." maskType:SVProgressHUDMaskTypeBlack];
                request=[IMServerAPI grouptChangeRoomName:self.chatName roomId:self.messageId block:^(BOOL status){

                    request=nil;
                    if(!status){
                        UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"操作失败，请检查网络！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                        alertView=nil;
                        return ;
                    }

                    [SVProgressHUD dismiss];
                    RectangleChat* rectangleChat=[[ShareAppDelegate xmpp] fetchRectangleChatFromJid:self.messageId isGroup:self.isGroupChat];
                    if(rectangleChat!=nil){
                        rectangleChat.name=self.chatName;
                        [rectangleChat didSave];
                    }
                    
                    if([self.delegate respondsToSelector:@selector(updateMemberName:memberName:)])
                        [self.delegate updateMemberName:self memberName:self.chatName];
                    [tableView reloadData];
                
                }];
                
            }
            else{
                UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"请输入群组名" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                alertView=nil;
            }
        }
    }
}

#pragma mark grouppanel  delegate

-(void)addGroupClick:(GroupPanel*)groupPanel{
    ContactSelectedForGroupViewController* controller=[[ContactSelectedForGroupViewController alloc] init];
    controller.existsGroupJid=self.messageId;
    controller.groupName=self.chatName;
    controller.selectedFriends=list;
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

-(void)removeGroupClick:(GroupPanel *)groupPanel{
    UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"你确定要将此联系人踢出群组吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag=778899;
    [alertView show];

}

#pragma mark contactselectedby group delegate

-(void)dismiss:(ContactSelectedForGroupViewController *)controller selectedInfo:(NSArray*)selectedInfo{
    if(selectedInfo!=nil){
        if(list==nil)
            list=[[NSMutableArray alloc] initWithCapacity:1];
        
        @autoreleasepool {
            for (UserInfo* userInfo in selectedInfo) {
                NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
                [dictionary setValue:userInfo.userJid forKey:@"jid"];
                [dictionary setValue:userInfo.userSex forKey:@"sex"];
                [dictionary setValue:[userInfo name] forKey:@"username"];
                [dictionary setValue:userInfo.userStatue forKey:@"statue"];
                [list addObject:dictionary];
            }
            
            [groupPanel setArray:list];
            [tableView reloadData];
        }
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




@end

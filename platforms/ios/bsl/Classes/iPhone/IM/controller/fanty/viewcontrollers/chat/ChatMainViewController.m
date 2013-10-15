//
//  ChatMainViewController.m
//  WeChat
//
//  Created by apple2310 on 13-9-5.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import "ChatMainViewController.h"
#import "ChatPanel.h"
#import "TouchScroller.h"
#import "ChatCell.h"
#import "ChatImageCell.h"
#import "ChatLogic.h"
#import "RecordingView.h"
#import "VoiceCell.h"
#import "Recorder.h"
#import "Base64.h"
#import "SVProgressHUD.h"
#import "ImageScroller.h"
#import "RectangleChat.h"
#import "GroupMemberManagerViewController.h"
#import "MessageRecord.h"
#import "XMPPSqlManager.h"
#import "IMServerAPI.h"

#import "VoiceUploadManager.h"

#import "GTGZImageDownloadedManager.h"

@interface ChatMainViewController ()<TouchScrollerDelegate,UITableViewDataSource,UITableViewDelegate,ChatPanelDelegate,NSFetchedResultsControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RecorderDelegate,UIPopoverControllerDelegate,ChatImageCellDelegate,GroupMemberManagerViewControllerDelegate,VoiceUploadManagerDelegate>
-(void)createRightNavBarButton;
-(void)initChatPanel;
-(void)scrollToBottom;
-(void)loadLocalData;
-(void)voiceButtonClick:(UIButton*)cell;
-(void)rightActionClick;
-(void)rightGroupClick;
@end

@implementation ChatMainViewController

@synthesize messageId;
@synthesize chatName;
@synthesize isGroupChat;
@synthesize isQuit;
- (id)init{
    self = [super init];
    if (self) {
        [VoiceUploadManager sharedInstance].delegate=self;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = YES;
        }

        playingIndex=-1;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[GTGZImageDownloadedManager sharedInstance] removeAll];
    
    self.title=self.chatName;
    
    recorder=[[Recorder alloc] init];
    recorder.delegate=self;
    
    chatLogic=[[ChatLogic alloc] init];

    if(self.isGroupChat)
        chatLogic.roomJID=self.messageId;
    
    
    [self createRightNavBarButton];
    
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emotionResource" ofType:@"plist"];
    emoctionList = [[NSDictionary alloc]initWithContentsOfFile:path];

    CGRect rect=self.view.frame;
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        rect.size.width =CGRectGetHeight(self.view.frame)/2+2;
        rect.size.height= CGRectGetWidth(self.view.frame)-self.navigationController.navigationBar.bounds.size.height;

        //rect.size.height=768.0f-self.navigationController.navigationBar.bounds.size.height-20.0f;
    }
    else{
        rect.size.height-=44.0f;
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
        rect.size.height-=20.0f;
    }

    self.view.frame=rect;
    
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ChatBackground_00.jpg"]];
    [self initChatPanel];
    rect=self.view.bounds;
    rect.size.height-=[chatPanel panelHeight];
    
    tableView=[[TouchTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView.dataSource=self;
    tableView.delegate=self;
    tableView.touchDelegate=self;
    tableView.showsHorizontalScrollIndicator=NO;
    tableView.showsVerticalScrollIndicator=NO;
    tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:tableView];
     
    [self.view addSubview:chatPanel];
    
    [self loadLocalData];
    
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
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    [[GTGZImageDownloadedManager sharedInstance] removeAll];
    
    tableView=nil;
    chatPanel=nil;

    [chatLogic cancel];
    chatLogic=nil;
    messageArray=nil;
        
    fetchController.delegate=nil;
    fetchController=nil;
    
    [recorder stop];
    recorder=nil;
    
    emoctionList=nil;
}

-(void)dealloc{
    [[GTGZImageDownloadedManager sharedInstance] removeAll];
    [VoiceUploadManager sharedInstance].delegate=nil;

    self.messageId=nil;
    self.chatName=nil;
    chatLogic=nil;

    fetchController.delegate=nil;
    [recorder stop];
    recorder=nil;
}

#pragma mark tableview delegate  datasource

- (void)tableView:(UIScrollView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event{
    [chatPanel resignFirstResponder];
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [chatPanel resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor=[UIColor clearColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messageArray count];
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id obj=[messageArray objectAtIndex:[indexPath row]];
    if([[obj class] isSubclassOfClass:[MessageEntity class]]){
        MessageEntity *messageEntity = (MessageEntity*)[messageArray objectAtIndex:[indexPath row]];
        
        if([messageEntity.type isEqualToString:@"voice"]){
            return [VoiceCell cellHeight:([messageEntity.sendUser isEqualToString:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]]?BubbleTypeMine:BubbleTypeSomeoneElse)];
        }
        else if([messageEntity.type isEqualToString:@"image"]){
            return [ChatImageCell cellHeight:([messageEntity.sendUser isEqualToString:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]]?BubbleTypeMine:BubbleTypeSomeoneElse)];
        }
        else{
            return [ChatCell cellHeight:messageEntity.content bubbleType:([messageEntity.sendUser isEqualToString:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]]?BubbleTypeMine:BubbleTypeSomeoneElse) emoctionList:emoctionList]+10.0f;
        }
    }
    else{
        return 30.0f;
    }
}


- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id obj=[messageArray objectAtIndex:[indexPath row]];
    
    if([[obj class] isSubclassOfClass:[MessageEntity class]]){
        MessageEntity *messageEntity = (MessageEntity*)[messageArray objectAtIndex:[indexPath row]];

        if([messageEntity.type isEqualToString:@"voice"]){
            VoiceCell *cell = (VoiceCell*)[_tableView dequeueReusableCellWithIdentifier:@"voice_cell"];
            if(cell == nil){
                cell = [[VoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"voice_cell"] ;
                [cell addVoiceButton:self action:@selector(voiceButtonClick:)];
                
                CGRect rect=cell.frame;
                rect.size.width=tableView.frame.size.width;
                cell.frame=rect;
            }
            cell.type=([messageEntity.sendUser isEqualToString:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]]?BubbleTypeMine:BubbleTypeSomeoneElse);
            [cell headerUrl:@""];
            [cell name:[messageEntity name]];
            [cell sendDate:messageEntity.sendDate];
            [cell playAnimated:([messageEntity.statue intValue]==1 && (playingIndex==[indexPath row]))];
            [cell voiceLength:1 animate:NO];
            cell.status=[messageEntity.statue intValue];
            cell.tag=[indexPath row];
            return cell;
        }
        else if([messageEntity.type isEqualToString:@"notification"]){
            UITableViewCell *cell = (UITableViewCell*)[_tableView dequeueReusableCellWithIdentifier:@"notification_cell"];
            if(cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notification_cell"] ;
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.textColor=[UIColor grayColor];
            cell.textLabel.font=[UIFont systemFontOfSize:16.0f];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
            cell.textLabel.text=messageEntity.content;
            return cell;

        }
        else if([messageEntity.type isEqualToString:@"image"]){
            ChatImageCell *cell = (ChatImageCell*)[_tableView dequeueReusableCellWithIdentifier:@"image_cell"];
            if(cell == nil){
                cell = [[ChatImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_cell"] ;
                cell.delegate=self;
                CGRect rect=cell.frame;
                rect.size.width=tableView.frame.size.width;
                cell.frame=rect;
            }
            [cell headerUrl:@"" name:[messageEntity name] imageFile:messageEntity.content sendDate:messageEntity.sendDate bubbleType:([messageEntity.sendUser isEqualToString:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]]?BubbleTypeMine:BubbleTypeSomeoneElse)];
            cell.tag=[indexPath row];
            
            return cell;

        }
        else{
            ChatCell *cell = (ChatCell*)[_tableView dequeueReusableCellWithIdentifier:@"chat_cell"];
            if(cell == nil){
                cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chat_cell"] ;
                CGRect rect=cell.frame;
                rect.size.width=tableView.frame.size.width;
                cell.frame=rect;
            }
            cell.emoctionList=emoctionList;
            [cell headerUrl:@"" name:[messageEntity name] content:messageEntity.content sendDate:messageEntity.sendDate bubbleType:([messageEntity.sendUser isEqualToString:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]]?BubbleTypeMine:BubbleTypeSomeoneElse)];
            cell.tag=[indexPath row];

            return cell;

        }
    }
    else if([[obj class] isSubclassOfClass:[NSString class]]){
        UITableViewCell *cell = (UITableViewCell*)[_tableView dequeueReusableCellWithIdentifier:@"date_cell"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"date_cell"] ;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.textColor=[UIColor grayColor];
        cell.textLabel.font=[UIFont systemFontOfSize:16.0f];
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.text=obj;
        return cell;
    }
    return nil;
}


-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [chatPanel resignFirstResponder];
}

#pragma mark chat panel delegate

-(void)chatPanelDidSend:(ChatPanel *)__chatPanel{
    
    AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate xmpp] isConnected]) {
        [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        return;
    }
    
    if(![chatLogic checkTheGroupIsConnect]){
        [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];
        return;
    }


    
    NSString *content = [__chatPanel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([content length]>0){
        if(![chatLogic sendMessage:content messageId:self.messageId isGroup:self.isGroupChat name:self.chatName]){
            [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];

            return;
        }
    }
    //把输入框清空
    __chatPanel.text = @"";

}

-(void)chatPanelRecordTouch:(ChatPanel *)chatPanel isTouch:(BOOL)touch{
    if(touch){
        AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (![[appDelegate xmpp] isConnected]) {
            [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
            return;
        }
        
        if(![chatLogic checkTheGroupIsConnect]){
            [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];
            return;
        }

        for(UITableViewCell* cell in [tableView visibleCells]){
            if([cell isKindOfClass:[VoiceCell class]]){
                [((VoiceCell*)cell) playAnimated:NO];
            }
        }
        playingIndex=-1;

        
        if(recordingView==nil){
            recordingView=[[RecordingView alloc] initWithFrame:self.view.bounds];
        }
        [self.view addSubview:recordingView];
        [recordingView startAnimation];
        
        
        [recorder record];

    }
    else{
        [recordingView stopAnimation];
        recordingView=nil;
        float addInterval=recorder.addInterval;
        [recorder stop];
    
        AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        if (![[appDelegate xmpp] isConnected]) {
            [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
            return;
        }
        if(![chatLogic checkTheGroupIsConnect]){
            [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];
            return;
        }


        if(addInterval>1.5f){
            if(![[VoiceUploadManager sharedInstance] sendVoice:recorder.recordFile messageId:self.messageId isGroup:self.isGroupChat name:self.chatName uqId:nil])
                [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"你讲话的时间太短了！"];
        }

    }
}

-(void)chatPanelRecordCancel:(ChatPanel *)chatPanel{
    @autoreleasepool {
        [recorder removeRecord];
        [recordingView stopAnimation];
        recordingView=nil;

    }

}

-(void)chatPanelDidSelectedAdd:(ChatPanel*)chatPanel{
    AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate xmpp] isConnected]) {
        [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        return;
    }
    
    if(![chatLogic checkTheGroupIsConnect]){
        [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];
        return;
    }


    //fanty 暂屏蔽功能
    if([[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipod"].length>0){
        UIActionSheet* sheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从手机相片图库中选取" otherButtonTitles:nil, nil];
        sheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self.view];

    }
    else{
        UIActionSheet* sheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从手机相片图库中选取", nil];
        sheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self.view];
        
    }
}

#pragma mark  chatimagecell delegate

-(void)chatImageCellDidSelect:(ChatImageCell *)cell url:(NSString *)url{
    AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    ImageScroller* view=[[ImageScroller alloc] initWithFrame:appDelegate.window.rootViewController.view.bounds];
    [view showImage:url];
    [view showInView:appDelegate.window.rootViewController.view];
    
    view=nil;
}

#pragma mark  recorder  delegate

-(void)recordDidPlayFinish:(Recorder *)recorder{
    for(UITableViewCell* cell in [tableView visibleCells]){
        if([cell isKindOfClass:[VoiceCell class]]){
            [((VoiceCell*)cell) playAnimated:NO];
        }
    }
    playingIndex=-1;
}

-(void)recordDidPlayError:(Recorder*)__recorder{
    [self recordDidPlayFinish:__recorder];
    [SVProgressHUD showErrorWithStatus:@"文件不存在"];
    playingIndex=-1;

}

-(void)recordTimeout:(Recorder *)__record{
    chatPanel.cancelRecond=YES;
    [self chatPanelRecordTouch:chatPanel isTouch:NO];
    
}

-(void)refreshAudioPower:(Recorder*)recorder level:(int)level{
    [recordingView changeLevel:level];
}

#pragma mark actionsheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==2)return;
    
    if([[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipod"].length>0 && buttonIndex==1)return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.videoQuality=UIImagePickerControllerQualityTypeHigh;
    picker.delegate = self;
    
    if(buttonIndex==1 || [[[[UIDevice currentDevice] model] lowercaseString] rangeOfString:@"ipod"].length>0){
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
            picker.mediaTypes = temp_MediaTypes;
            
        }
    }
    else{
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
            
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            
        }
    }
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
        popover.delegate=nil;
        [popover dismissPopoverAnimated:NO];
        popover=nil;
        popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            [picker.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
        popover.delegate=self;
        [popover presentPopoverFromRect:CGRectMake(0.0f, 0.0f, 320.0f, 600.0f) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    }
    else{
        [self presentViewController:picker animated:YES completion:^{}];
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


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    picker.delegate=nil;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]){
        
        AppDelegate* appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([[appDelegate xmpp] isConnected]) {

            @autoreleasepool {
                NSString *imageKey = @"UIImagePickerControllerOriginalImage";
                UIImage* image=nil;
                image=[info objectForKey:imageKey];
                if(image!=nil && picker.sourceType==UIImagePickerControllerSourceTypeCamera){
                    UIImageWriteToSavedPhotosAlbum(image, nil,nil, nil);
                }
                
                [SVProgressHUD showWithStatus:@"上传中..." maskType:SVProgressHUDMaskTypeBlack];
                [chatLogic uploadImageToServer:image finish:^(NSString* fileId,NSString* path){
                    if([fileId length]>0){
                        [SVProgressHUD dismiss];
                        if(![chatLogic sendfile:fileId path:path messageId:self.messageId isGroup:self.isGroupChat name:self.chatName]){
                            [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];
                        }
                    }
                    else{
                        [SVProgressHUD dismiss];
                        [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
                    }
                }];
            }
            

        }
        else{
            [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        }

        
    }
    if(popover!=nil){
        popover.delegate=nil;
        [popover dismissPopoverAnimated:NO];
        popover=nil;
    }
    else{
        [picker dismissModalViewControllerAnimated:YES];
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    picker.delegate=nil;
    
    if(popover!=nil){
        popover.delegate=nil;
        [popover dismissPopoverAnimated:NO];
        popover=nil;
    }
    else{
        [picker dismissModalViewControllerAnimated:YES];
    }
    
    
}

#pragma mark fetchedResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    if ([anObject isKindOfClass:[MessageEntity class]]&&type==NSFetchedResultsChangeInsert) {
        
        MessageEntity *messageEntity = (MessageEntity*)anObject;

       
        NSMutableArray* indexPathArray=[NSMutableArray arrayWithCapacity:1];
        
        
        // 暂作保留
        if(messageEntity.receiveDate!=nil){
            BOOL addDate=YES;
            
            NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString* nDate=[formatter stringFromDate:messageEntity.receiveDate];

            for(int i=[messageArray count]-1;i>=0;i--){
                id obj=[messageArray objectAtIndex:i];
                if([[obj class] isSubclassOfClass:[NSString class]]){
                    NSString* lastestDate=obj;
                    
                    if([lastestDate isEqualToString:nDate]){
                        addDate=NO;
                    }
                    break;
                }
            }
            
            if(addDate){
                [messageArray addObject:nDate];
                [indexPathArray addObject:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0]];

            }
        }
        
        [messageArray addObject:messageEntity];

        [indexPathArray addObject:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0]];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        RectangleChat* rectChat=[appDelegate.xmpp fetchRectangleChatFromJid:self.messageId isGroup:self.isGroupChat];
        rectChat.noReadMsgNumber=[NSNumber numberWithInt:0];
        [appDelegate.xmpp saveContext];
        
        
        [MessageRecord createModuleBadge:@"com.foss.chat" num: [XMPPSqlManager getMessageCount]];

        

        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationBottom];
        [tableView scrollToRowAtIndexPath:[indexPathArray lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        if([rectChat.isQuit boolValue]){
            [chatPanel hideAllControlPanel];
            [self.navigationController popViewControllerAnimated:YES];
        }

        
    }else if (type==NSFetchedResultsChangeUpdate) {
        [tableView reloadData];
    }
}


#pragma mark voiceuploadmanager  delegate

-(void)voiceUploadFinish:(NSString *)messageId finish:(BOOL)finish{
    if(!finish){
        [SVProgressHUD showErrorWithStatus:@"语音发送失败！"];
    }
}

-(void)voiceDownloadFinish:(NSString*)uqId finish:(BOOL)finish{
    if(!finish){
        [SVProgressHUD showErrorWithStatus:@"语音接收失败！"];
    }
    else if(playingIndex>-1){
        
        for(UITableViewCell* __cell in [tableView visibleCells]){
            if([__cell isKindOfClass:[VoiceCell class]]){
                [((VoiceCell*)__cell) playAnimated:NO];
                if(__cell.tag==playingIndex){
                    MessageEntity* entity=[messageArray objectAtIndex:playingIndex];
                    [((VoiceCell*)__cell) playAnimated:YES];
                    [recorder play:[NSURL URLWithString:entity.content]];
                }
            }
        }
    }
}

#pragma mark groupmember controller

-(void)updateMemberName:(GroupMemberManagerViewController *)controller memberName:(NSString *)memberName{
    self.chatName=memberName;
    self.title=self.chatName;
}

-(void)deleteMember:(GroupMemberManagerViewController *)controller{
    self.isQuit=YES;
    [chatPanel hideAllControlPanel];
    [self createRightNavBarButton];
}

#pragma mark method


-(void)voiceButtonClick:(UIButton*)button{
    [chatPanel resignFirstResponder];
    VoiceCell* cell=(VoiceCell*)button.superview;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
        cell=(VoiceCell*)cell.superview;
    }
    

    for(UITableViewCell* __cell in [tableView visibleCells]){
        if([__cell isKindOfClass:[VoiceCell class]]){
            [((VoiceCell*)__cell) playAnimated:NO];
            if(cell.tag==__cell.tag){
                cell=(VoiceCell*)__cell;
            }
        }
    }
    if(playingIndex==cell.tag){
        [cell playAnimated:NO];
        [recorder stop];
        playingIndex=-1;
    }
    else{
        playingIndex=cell.tag;
        MessageEntity* entity=[messageArray objectAtIndex:cell.tag];
        if([entity.statue intValue]==-1 || [entity.statue intValue]==-2){
            if([entity.sendUser isEqualToString:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]]){
                playingIndex=-1;
                if(![[VoiceUploadManager sharedInstance] sendVoice:entity.content messageId:self.messageId isGroup:self.isGroupChat name:self.chatName uqId:entity.uqID])
                    [SVProgressHUD showErrorWithStatus:@"该群组被断开连接，正在尝试重连！"];
            }
            else{
                [[VoiceUploadManager sharedInstance] receiveVoice:entity.content uqId:entity.uqID messageId:entity.messageId isGroup:self.isGroupChat];
            }
        }
        else{
            [cell playAnimated:YES];
            [recorder play:[NSURL URLWithString:entity.content]];
        }
    }
}

-(void)rightActionClick{
    [SVProgressHUD showWithStatus:@"操作执行中..." maskType:SVProgressHUDMaskTypeBlack];
    if([chatLogic isInFaviorContacts:self.messageId]){
        
        [IMServerAPI deleteCollectIMFriend:self.messageId block:^(BOOL status){
        
            if(!status){
                [SVProgressHUD showErrorWithStatus:@"操作失败，请稍后再试！"];
            }
            else{
                [chatLogic removeFaviorInContacts:self.messageId];
                [SVProgressHUD showSuccessWithStatus:@"你已取消关注该好友"];
            }
            [self createRightNavBarButton];

        }];
    }
    else{
        [IMServerAPI collectIMFriend:self.messageId block:^(BOOL status){
            if(!status){
                [SVProgressHUD showErrorWithStatus:@"操作失败，请稍后再试！"];
            }
            else{
                [chatLogic addFaviorInContacts:self.messageId];
                [SVProgressHUD showSuccessWithStatus:@"你已成功关注该好友"];
            }
            [self createRightNavBarButton];

        }];

    }
    
}

-(void)rightGroupClick{
    GroupMemberManagerViewController* controller=[[GroupMemberManagerViewController alloc] init];
    controller.delegate=self;
    controller.messageId=self.messageId;
    controller.chatName=self.chatName;
    controller.isGroupChat=self.isGroupChat;
    controller.isQuit=self.isQuit;
    [self.navigationController pushViewController:controller animated:YES];
}


-(void)createRightNavBarButton{
    
    if(self.isQuit){
        self.navigationItem.rightBarButtonItem=nil;
        
    }
    else{
        UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 63, 30)];
        
        
        UIImage* img=[UIImage imageNamed:@"nav_add_btn.png"];
        img=[img stretchableImageWithLeftCapWidth:img.size.width*0.5f topCapHeight:img.size.height*0.5f];
        [navRightButton setBackgroundImage:img forState:UIControlStateNormal];
        [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
        
        img=[UIImage imageNamed:@"nav_add_btn_active.png"];
        img=[img stretchableImageWithLeftCapWidth:img.size.width*0.5f topCapHeight:img.size.height*0.5f];
        [navRightButton setBackgroundImage:img forState:UIControlStateHighlighted];
        if(!self.isGroupChat){
            if(![chatLogic isInFaviorContacts:self.messageId])
                [navRightButton setTitle:@"添加关注" forState:UIControlStateNormal];
            else
                [navRightButton setTitle:@"取消关注" forState:UIControlStateNormal];
            [navRightButton addTarget:self action:@selector(rightActionClick) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else{
            [navRightButton setTitle:@"管理" forState:UIControlStateNormal];
            [navRightButton addTarget:self action:@selector(rightGroupClick) forControlEvents:UIControlEventTouchUpInside];
            
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    }
}


-(void)loadLocalData{

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %@",self.messageId];
    NSFetchRequest *fetechRequest = [NSFetchRequest fetchRequestWithEntityName:@"MessageEntity"];
    [fetechRequest setPredicate:predicate];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"sendDate" ascending:YES];
    [fetechRequest setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
    //viewController之间互相传递数据的方法之一
    fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetechRequest
                                                         managedObjectContext:appDelegate.xmpp.managedObjectContext
                                                           sectionNameKeyPath:nil cacheName:nil];
    fetchController.delegate = self;
    [fetchController performFetch:NULL];
    
    //把消息都保存在messageArray中
    NSArray *contentArray = [fetchController fetchedObjects];
    messageArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    for(MessageEntity* messageEntity in contentArray){
        // 暂作保留
        if(messageEntity.receiveDate!=nil){
            BOOL addDate=YES;
            
            NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString* nDate=[formatter stringFromDate:messageEntity.receiveDate];
            
            for(int i=[messageArray count]-1;i>=0;i--){
                id obj=[messageArray objectAtIndex:i];
                if([[obj class] isSubclassOfClass:[NSString class]]){
                    NSString* lastestDate=obj;
                    
                    if([lastestDate isEqualToString:nDate]){
                        addDate=NO;
                    }
                    break;
                }
            }
            if(addDate){
                [messageArray addObject:nDate];
            }
        }
        [messageArray addObject:messageEntity];

    }
    
    
    RectangleChat* rectChat=[appDelegate.xmpp fetchRectangleChatFromJid:self.messageId isGroup:self.isGroupChat];
    rectChat.noReadMsgNumber=[NSNumber numberWithInt:0];
    [appDelegate.xmpp saveContext];
    
    [MessageRecord createModuleBadge:@"com.foss.chat" num: [XMPPSqlManager getMessageCount]];


    //设置contentOffset才能完整显示最后一条消息,scrollToRect,scrollToIndexPath都不行
    if([messageArray count]>0)
        [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.05];
    
}


-(void)scrollToBottom{
    if([messageArray count]>1)
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
}

-(void)initChatPanel{
    chatPanel=[[ChatPanel alloc] initWithFrame:self.view.bounds];
    chatPanel.delegate=self;
    chatPanel.emoctionList=emoctionList;
    if(self.isQuit)
        [chatPanel hideAllControlPanel];
    
#ifdef MOBILE_BSL
    //移动运行网暂不要群组发语音
    if(self.isGroupChat){
        [chatPanel disableChatButton];
    }
#endif
    
    CGRect rect=chatPanel.frame;
    rect.origin.y=self.view.bounds.size.height-[chatPanel panelHeight];
    chatPanel.frame=rect;
    chatPanel.superViewHeight=self.view.frame.size.height;
}

@end

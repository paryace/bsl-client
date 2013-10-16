//
//  RecentTalkView.m
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import "RecentTalkView.h"
#import "RectangleChat.h"
#import "RectangleCell.h"
#import "SVProgressHUD.h"
#import "IMServerAPI.h"
#import "HTTPRequest.h"
#import "GTGZImageDownloadedManager.h"
#import "MessageRecord.h"
#import "XMPPSqlManager.h"
#import "ChatLogic.h"

@interface RecentTalkView()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIAlertViewDelegate>{
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;

}

-(void)delayReloadTimeEvent;
@end

@implementation RecentTalkView
@synthesize rectentDelegate;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        
        deleteIndex=-1;
        
        self.dataSource=self;
        self.delegate=self;
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
        list=[[NSMutableArray alloc] initWithCapacity:2];
        managedObjectContext = [ShareAppDelegate xmpp].managedObjectContext;
        
        
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
        
        [fetchedResultsController performFetch:nil];

        
        [self delayReloadTimeEvent];
        
    }
    return self;
}

- (void)dealloc{
    [request cancel];
    [alertView dismissWithClickedButtonIndex:0 animated:NO];
    [laterReloadTimer invalidate];
    fetchedResultsController.delegate=nil;
}

#pragma mark method

-(void)delayReloadTimeEvent{
    [laterReloadTimer invalidate];
    laterReloadTimer=nil;
    
    [list removeAllObjects];
    [alertView dismissWithClickedButtonIndex:0 animated:NO];
    alertView=nil;
    deleteIndex=-1;
    
    NSArray *contentArray = [fetchedResultsController fetchedObjects];
    for(id obj in contentArray){
        [list addObject:obj];
    }

    
    [self reloadData];
}

#pragma mark tableview delegate  datasource


-(UITableViewCellEditingStyle)tableView:(UITableView *)__tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(__tableView.editing)
        return  UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        deleteIndex=[indexPath row];
        RectangleChat* model=[list objectAtIndex:deleteIndex];
        if([model.isGroup boolValue] && ![model.isQuit boolValue]){
            
            if([model.createrJid isEqualToString:[[ShareAppDelegate xmpp].xmppStream.myJID bare]]){
                alertView=[[UIAlertView alloc] initWithTitle:@"你确定要解散该群组并删除所有聊天信息吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
            }
            else{
                alertView=[[UIAlertView alloc] initWithTitle:@"你确定要退出该群组并删除所有聊天信息吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
            }

        }
        else{
            alertView=[[UIAlertView alloc] initWithTitle:@"你确定要删除该聊天信息吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];

        }
        [alertView show];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [list count];
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [RectangleCell height];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RectangleCell *cell = (RectangleCell*)[_tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[RectangleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    RectangleChat* model=[list objectAtIndex:[indexPath row]];
    [cell headerUrl:@"" title:model.name content:model.content date:model.updateDate];
    [cell number:[model.noReadMsgNumber intValue]];
    RectangleCellType type=RectangleCellTypeMessage;
    if([model.contentType intValue]==RectangleChatContentTypeImage)
        type=RectangleCellTypeImage;
    else if([model.contentType intValue]==RectangleChatContentTypeVoice)
        type=RectangleCellTypeVoice;
    [cell rectangleType:type];
    return cell;
}


-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RectangleChat* model=[list objectAtIndex:[indexPath row]];

    if([self.rectentDelegate respondsToSelector:@selector(rectentTalkViewDidSelected:rectangleChat:)])
        [self.rectentDelegate rectentTalkViewDidSelected:self rectangleChat:model];
}


#pragma mark  fetchedresultscontroller  delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    if(![anObject isKindOfClass:[RectangleChat class]])return;
    if (type==NSFetchedResultsChangeInsert) {
        [laterReloadTimer invalidate];
        laterReloadTimer=[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(delayReloadTimeEvent) userInfo:nil repeats:NO];

    }else if (type==NSFetchedResultsChangeUpdate) {
        [laterReloadTimer invalidate];
        laterReloadTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayReloadTimeEvent) userInfo:nil repeats:NO];
    }
    else if(type==NSFetchedResultsChangeDelete){
        [list removeObjectAtIndex:[indexPath row]];
        
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
//        [laterReloadTimer invalidate];
//        laterReloadTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayReloadTimeEvent) userInfo:nil repeats:NO];
    }
    else if(type==NSFetchedResultsChangeMove){
        
    }
}

#pragma mark alertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        RectangleChat* model=[list objectAtIndex:deleteIndex];
        if([model.isGroup boolValue]  && ![model.isQuit boolValue]){
            BOOL isMyGroup=[model.createrJid isEqualToString:[[ShareAppDelegate xmpp].xmppStream.myJID bare]];
            [request cancel];
            [SVProgressHUD showWithStatus:@"正在执行退出..." maskType:SVProgressHUDMaskTypeBlack];
            
            if(!isMyGroup){
                request=[IMServerAPI grouptDeleteMember:[[ShareAppDelegate xmpp].xmppStream.myJID bare] roomId:model.receiverJid block:^(BOOL status){
                    [self quitGroupAction:status];
                }];
            }
            else{
                request=[IMServerAPI grouptDeleteRoom:model.receiverJid block:^(BOOL status){
                    [self quitGroupAction:status];
                }];
            }
        }
        else{
            [self quitGroupAction:YES];

        }
    }
}


-(void)quitGroupAction:(BOOL)status{
    request=nil;
    
    if(!status){
        deleteIndex=-1;
        [SVProgressHUD showErrorWithStatus:@"操作失败，请检查网络！"];
        return ;
    }
    [SVProgressHUD dismiss];
    RectangleChat* model=[list objectAtIndex:deleteIndex];
    
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %@",model.receiverJid];
    NSFetchRequest *fetechRequest = [NSFetchRequest fetchRequestWithEntityName:@"MessageEntity"];
    [fetechRequest setPredicate:predicate];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"sendDate" ascending:YES];
    [fetechRequest setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
    //viewController之间互相传递数据的方法之一
    NSFetchedResultsController* fetch = [[NSFetchedResultsController alloc]initWithFetchRequest:fetechRequest
                                                         managedObjectContext:managedObjectContext
                                                           sectionNameKeyPath:nil cacheName:nil];
    [fetch performFetch:NULL];
    NSArray *contentArray = [fetch fetchedObjects];

    NSFileManager* fileManager=[NSFileManager defaultManager];
    for(MessageEntity* messageEntity in contentArray){

        NSError* error=nil;
        if([messageEntity.type isEqualToString:@"voice"]){
            
            [fileManager removeItemAtPath:messageEntity.content error:&error];
        }
        else if([messageEntity.type isEqualToString:@"image"]){
            
            [fileManager removeItemAtPath:[[GTGZImageDownloadedManager sharedInstance] originPathByUrl:messageEntity.content] error:&error];
        }
        [managedObjectContext deleteObject:messageEntity];
    }

    fetch=nil;
    
    if([model.isGroup boolValue]  && ![model.isQuit boolValue]){
        BOOL isMyGroup=[model.createrJid isEqualToString:[[ShareAppDelegate xmpp].xmppStream.myJID bare]];
        ChatLogic* logic=[[ChatLogic alloc] init];
        logic.roomJID=model.receiverJid;
        [logic sendRoomQuitAction:model.receiverJid isMyGroup:isMyGroup];
        logic=nil;

    }

    
    [managedObjectContext deleteObject:model];
    [managedObjectContext save:nil];
    deleteIndex=-1;

    [MessageRecord createModuleBadge:@"com.foss.chat" num: [XMPPSqlManager getMessageCount]];

}


@end

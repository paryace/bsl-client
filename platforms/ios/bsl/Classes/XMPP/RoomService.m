//
//  RoomService.m
//  cube-ios
//
//  Created by 肖昶 on 13-9-17.
//
//

#import "RoomService.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoom.h"
#import "RectangleChat.h"
#import "Base64.h"
#import "HTTPRequest.h"
#import "IMServerAPI.h"
#import "MessageRecord.h"
#import "XMPPSqlManager.h"
#import "ChatLogic.h"

@interface RoomService()<NSFetchedResultsControllerDelegate,XMPPRoomDelegate>

-(void)checkTimerEvent;
-(void)delayRemoveNewRoom:(NSString*)roomId;
@end

@implementation RoomService

-(id)init{
    self=[super init];
    if(self){
        rooms=[[NSMutableArray alloc] initWithCapacity:2];
    }
    
    return self;
}

-(void)dealloc{
    
    [self tearDown];
}

-(void)joinAllRoomService{
    if(checkTimer!=nil)return;
    [self tearDown];
    
    request=[IMServerAPI grouptGetRooms:[[ShareAppDelegate xmpp].xmppStream.myJID bare] block:^(BOOL status,NSArray* array){
        request=nil;
        
        XMPPIMActor* xmpp=[ShareAppDelegate xmpp];

        @autoreleasepool {
            @autoreleasepool {
                
                for(NSDictionary* dict in array){
                    NSString* jid=[dict objectForKey:@"roomId"];
                    NSString* userJid=[dict objectForKey:@"creator"];
                    NSString* roomName=[dict objectForKey:@"roomName"];
                    
                    if([jid length]<1 || [userJid length]<1)continue;
                    RectangleChat* rectChat=[xmpp fetchRectangleChatFromJid:jid isGroup:YES];

                    if(rectChat==nil){

                        if([[xmpp.xmppStream.myJID bare] isEqualToString:userJid]){
                            [xmpp newRectangleMessage:jid name:roomName content:@"" contentType:RectangleChatContentTypeMessage isGroup:YES createrJid:userJid];

                        }
                        else{
                            NSString* content=[NSString stringWithFormat:@"%@邀请你加入群组",[dict objectForKey:@"username"] ];
                            [xmpp newRectangleMessage:jid name:roomName content:content contentType:RectangleChatContentTypeMessage isGroup:YES createrJid:userJid];
                        }
                        
                    }
                    else{
                        if([roomName length]>0)
                            rectChat.name=roomName;
                        rectChat.isQuit=[NSNumber numberWithBool:NO];
                        //rectChat.createrJid=[dict objectForKey:@"jid"];
                    }
                }
                
                [xmpp saveContext];
                
            }
            
            
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            // Edit the entity name as appropriate.
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"RectangleChat" inManagedObjectContext:xmpp.managedObjectContext];
            [fetchRequest setEntity:entity];
            //排序
            
            NSSortDescriptor*sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"updateDate"ascending:NO];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,nil];
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSFetchedResultsController* fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[ShareAppDelegate xmpp].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
            
            [fetchedResultsController performFetch:nil];
            
            NSArray *contentArray = [fetchedResultsController fetchedObjects];

            ChatLogic* logic=[[ChatLogic alloc] init];
            for(RectangleChat* chat in contentArray){
                if([chat.isGroup boolValue] && ![chat.isQuit boolValue] && [chat.receiverJid length]>0){
                    BOOL isFind=NO;
                    for(NSDictionary* dict in array){
                        NSString* jid=[dict objectForKey:@"roomId"];
                        if([chat.receiverJid isEqualToString:jid]){
                            isFind=YES;
                            break;
                        }
                    }
                    if(!isFind){
                        chat.isQuit=[NSNumber numberWithBool:YES];
                        chat.content=@"该群已被解散";
                        chat.contentType=[NSNumber numberWithInt:RectangleChatContentTypeMessage];
                        
                        [logic sendNotificationMessage:@"该群已被解散" messageId:chat.receiverJid isGroup:YES name:nil onlyUpdateChat:YES];
                        
                    }
                }
            }
            logic=nil;
            
            
            for(RectangleChat* chat in contentArray){
                if([chat.isGroup boolValue] && ![chat.isQuit boolValue] && [chat.receiverJid length]>0){
                    [self joinRoomServiceWithRoomID:chat.receiverJid];
                }
            }
            [xmpp saveContext];

            
            checkTimer=[NSTimer scheduledTimerWithTimeInterval:8.0f target:self selector:@selector(checkTimerEvent) userInfo:nil repeats:YES];
        }
        
        
    }];
}

-(XMPPRoom*)findRoomByJid:(NSString*)roomId{
    for(XMPPRoom* room in rooms){
        NSString* roomJID=[room.roomJID bare];
        if([roomJID isEqualToString:roomId]){
            
            return room;
        }
    }
    return nil;
}


-(void)joinRoomServiceWithRoomID:(NSString*)__roomID{
    XMPPRoom* newRoom=[[XMPPRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:__roomID]];
    
    [rooms addObject:newRoom];
    
    [newRoom activate:[self getCurrentStream]];
    [newRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if ([newRoom preJoinWithNickname:[self getCurrentUserName]]){
        [newRoom joinRoomUsingNickname:[self getCurrentUserName] history:nil];
    }
    
    //[self performSelector:@selector(ConfigureNewRoom:) withObject:newRoom afterDelay:3.0];
}


-(NSString*)createNewRoom{
    NSString* newJid=[self getGenerateUUID];
    XMPPRoom* newRoom=[[XMPPRoom alloc]initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:newJid]];
    [rooms addObject:newRoom];
    [newRoom activate:[self getCurrentStream]];
    [newRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    if ([newRoom preJoinWithNickname:[self getCurrentUserName]])
    {
        [newRoom joinRoomUsingNickname:[self getCurrentUserName] history:nil];
    }
    
    //    [self ConfigureNewRoom:_room];
    //[self performSelector:@selector(ConfigureNewRoom:) withObject:newRoom afterDelay:3.0f];
    return newJid;
}

-(void)removeNewRoom:(NSString*)roomId destory:(BOOL)destory{
    [rooms enumerateObjectsUsingBlock:^(id obj,NSUInteger index,BOOL*stop){
        XMPPRoom* room=(XMPPRoom*)obj;
        NSString* roomJID=[room.roomJID bare];
        if([roomJID isEqualToString:roomId]){
            if(destory)
                [room destoryRoom];
            [room removeDelegate:self];
            [room deactivate];
            [rooms removeObject:room];
            *stop=YES;
            return;
        }

    }];
}

////配置room
-(void)ConfigureNewRoom:(XMPPRoom *)sender
{
    [sender fetchConfigurationForm];
    [sender configureRoomUsingOptions:nil];
}

-(NSString*)getGenerateUUID{
    XMPPStream *stream = [self getCurrentStream];
    NSString *newMUCStr =[NSString stringWithFormat:@"%@@%@",[stream generateUUID],kMUCSevericeDomin];
    return newMUCStr;
}

-(XMPPStream*)getCurrentStream{
    XMPPStream *stream = [ShareAppDelegate xmpp].xmppStream;
    return stream;
}

-(NSString*)getCurrentUserName{
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    //NSString* username= [defaults objectForKey:@"username"];
    return [[[[ShareAppDelegate xmpp] xmppStream] myJID] bare];
    //return username;
}



-(void)tearDown{
    [request cancel];
    request=nil;
    [checkTimer invalidate];
    checkTimer=nil;
    for(XMPPRoom* room in rooms){
        [room removeDelegate:self];
        [room deactivate];
    }
    [rooms removeAllObjects];
}

-(void)checkTimerEvent{
    for(XMPPRoom* room in rooms){
        if(!room.isJoined){
            [room removeDelegate:self];
            [room deactivate];
            
            [room activate:[self getCurrentStream]];
            [room addDelegate:self delegateQueue:dispatch_get_main_queue()];

            if ([room preJoinWithNickname:[self getCurrentUserName]]){
                [room joinRoomUsingNickname:[self getCurrentUserName] history:nil];
            }
        }
    }
}

#pragma RoomDelegate

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
//    self.roomID =[NSString stringWithFormat:@"%@",sender.myRoomJID.bare];
//    self.roomName=[NSString stringWithFormat:@"%@",sender.roomJID];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPP_CREATEROOM_NOTIFICATION" object:sender];
    
}


- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    /*
     if (self.roomDidJoinBlock) {
     self.roomDidJoinBlock();
     self.roomDidJoinBlock=nil;
     }
     */
    
    [self performSelector:@selector(ConfigureNewRoom:) withObject:sender afterDelay:2.0f];
}


- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    //    if([iqResult.type isEqualToString:@"result"])
    //    {
    //
    //    }
    NSLog(@"认证成功");

}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender{
    NSLog(@"房间已经销毁!");
}


- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    
    /*
    @autoreleasepool {
    
        NSXMLElement* element=[presence elementForName:@"x"];
        element=[element elementForName:@"item"];
        
        
        NSString* jid=[[[element attributes] objectAtIndex:0] stringValue];
        
        NSRange range = [jid rangeOfString:@"/"];
        if (range.location ==NSNotFound) {
            return;
        }
        
        XMPPIMActor* xmpp=[ShareAppDelegate xmpp];
        
        jid = [jid substringToIndex:range.location];
        
        
        NSString* roomId=[[sender roomJID] bare];
        UserInfo* info=[[ShareAppDelegate xmpp] fetchUserFromJid:jid];
        ChatLogic* logic=[[ChatLogic alloc] init];

        if(info!=nil){
            if([xmpp fetchGroupRoomUser:roomId memberId:jid]==nil){
                [logic sendNotificationMessage:[NSString stringWithFormat:@"%@加入了聊天室", [info name]] messageId:roomId isGroup:YES name:nil onlyUpdateChat:YES];
            }
            else{
                //[logic sendNotificationMessage:[NSString stringWithFormat:@"%@进入了聊天室", [info name]] messageId:roomId isGroup:YES name:nil];

            }
            
            [xmpp addGroupRoomMember:roomId memberId:jid sex:info.userSex status:info.userStatue username:info.userName];
        }
        else{
            NSRange range = [roomId rangeOfString:@"@"];
            NSString * result1 = [roomId substringToIndex:range.location];
            
            if([xmpp fetchGroupRoomUser:roomId memberId:jid]==nil){
                [logic sendNotificationMessage:[NSString stringWithFormat:@"%@加入了聊天室", result1] messageId:roomId isGroup:YES name:nil onlyUpdateChat:YES];
            }
            else{
                //[logic sendNotificationMessage:[NSString stringWithFormat:@"%@进入了聊天室", result1] messageId:roomId isGroup:YES name:nil];

            }
            
            [xmpp addGroupRoomMember:roomId memberId:jid sex:@"" status:@"在线" username:result1];
            
        }
        logic=nil;
        [xmpp saveContext];
    }
    */
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"离开了聊天室");
    

    /*
    @autoreleasepool {
        
        NSXMLElement* element=[presence elementForName:@"x"];
        element=[element elementForName:@"item"];
        
        
        NSString* jid=[[[element attributes] objectAtIndex:0] stringValue];
        
        NSRange range = [jid rangeOfString:@"/"];
        if (range.location ==NSNotFound) {
            return;
        }
        
        XMPPIMActor* xmpp=[ShareAppDelegate xmpp];
        
        jid = [jid substringToIndex:range.location];
        
        
        NSString* roomId=[[sender roomJID] bare];
        UserInfo* info=[[ShareAppDelegate xmpp] fetchUserFromJid:jid];
        ChatLogic* logic=[[ChatLogic alloc] init];
        
        if(info!=nil){
            [logic sendNotificationMessage:[NSString stringWithFormat:@"%@离开了聊天室", [info name]] messageId:roomId isGroup:YES name:nil];
            
        }
        else{
            NSRange range = [roomId rangeOfString:@"@"];
            NSString * result1 = [roomId substringToIndex:range.location];

            [logic sendNotificationMessage:[NSString stringWithFormat:@"%@离开了聊天室", result1] messageId:roomId isGroup:YES name:nil];

        }
        logic=nil;
        [xmpp saveContext];
    }
    */
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"聊天室更新");
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
    NSLog(@"认证失败");
    
    /*
    <iq xmlns="jabber:client" type="error" id="F7723F4C-68E2-4076-8D57-81999F8E25F8" from="8850ca32-fd95-4857-a555-5ad014c088e1@conference.snda-192-168-2-32" to="guodong@snda-192-168-2-32/Cube_Client11"><query xmlns="http://jabber.org/protocol/muc#owner"><x xmlns="jabber:x:data" type="submit"></x></query><error code="403" type="auth"><forbidden xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"></forbidden></error></iq>

     */
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"didFetchMembersList:[%@]",items);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items{
    NSLog(@"didFetchBanList:[%@]",items);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    NSLog(@"didFetchModeratorsList:[%@]",items);
}


-(void)delayRemoveNewRoom:(NSString*)roomId{
    [self removeNewRoom:roomId destory:NO];
}

//for groupchat 来自群聊的消息
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    if([message isMessageWithBody]){
        NSRange range = [message.fromStr rangeOfString:@"/"];
        if (range.location ==NSNotFound) {
            return;
        }
        NSString *roomId = [message.fromStr substringToIndex:range.location];
        NSString *senderUser =  [message.fromStr substringFromIndex:range.location +1];
        if([senderUser isEqualToString:[sender myNickname]]){
            return;
        }
        NSString *uqID = [[message attributeForName:@"uqID"] stringValue];
        if(uqID==nil){
            NSXMLElement* properties=[message elementForName:@"properties"];
            if(properties!=nil){
                NSArray* array=[properties elementsForName:@"property"];
                for(NSXMLElement* property in array){
                    if([[[property elementForName:@"name"] stringValue] isEqualToString:@"uqID"]){
                        uqID=[[property elementForName:@"value"] stringValue];
                        break;
                    }
                }
            }
        }
        
        XMPPIMActor* xmpp=[ShareAppDelegate xmpp];
        if(uqID==nil){
            uqID=[NSString stringWithFormat:@"rect_%f",[[NSDate date] timeIntervalSince1970]];
        }

        if(uqID!=nil && [xmpp fetchMessageFromUqID:uqID messageId:roomId]!=nil)
            return;
        
        
        @autoreleasepool {
            
            NSString* subject=[[message elementForName:@"subject"] stringValue];
            NSString* msg=[[message elementForName:@"body"] stringValue];
            
            if([subject isEqualToString:@"killperson"]){
                if(![msg isEqualToString:[xmpp.xmppStream.myJID bare]]){
                    return;
                }
            }
            
            MessageEntity *messageEntity = [NSEntityDescription insertNewObjectForEntityForName:@"MessageEntity" inManagedObjectContext: xmpp.managedObjectContext];
            
            messageEntity.uqID=uqID;
            messageEntity.messageId=roomId;
            messageEntity.sendUser=[NSString stringWithFormat:@"%@@@%@",senderUser,kXMPPDomin];
            messageEntity.receiveUser=[[xmpp.xmppStream myJID]bare];
            messageEntity.statue=[NSNumber numberWithInt:1];
            RectangleChatContentType rectangleChatContentType=RectangleChatContentTypeMessage;
            
            
            if ([ subject isEqualToString:@"voice"]) {
                //将字符串转换成nsdata
                
                /*
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex: 0];
                NSURL* urlVoiceFile= [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];

                @autoreleasepool {
                    NSData* fileData =  [Base64 decodeString:msg];
                    [fileData writeToURL:urlVoiceFile atomically:YES];
                }
                
                messageEntity.content = [urlVoiceFile absoluteString];
                 */
                messageEntity.content=msg;
                messageEntity.type = @"voice";
                messageEntity.statue=[NSNumber numberWithInt:-2];
                rectangleChatContentType=RectangleChatContentTypeVoice;
            }
            else if ([ subject isEqualToString:@"image"]) {
                messageEntity.content = msg;
                messageEntity.type = @"image";
                rectangleChatContentType=RectangleChatContentTypeImage;
            }
            else if ([ subject isEqualToString:@"quitgroup"]) {
                messageEntity.type = @"notification";
                messageEntity.content=@"群组已经被解散";
            }
            else if ([ subject isEqualToString:@"quitperson"]) {
                messageEntity.type = @"notification";
                messageEntity.content=[NSString stringWithFormat:@"%@已经退出群组",[sender myNickname]];
            }
            else if([subject isEqualToString:@"killperson"]){
                messageEntity.type = @"notification";
                messageEntity.content=@"你已被请出群组";

            }
            else{
                messageEntity.content = msg;
                messageEntity.type = @"text";
            }
            
            messageEntity.flag_readed = [NSNumber numberWithBool:NO];
            messageEntity.sendDate = [NSDate date];
            messageEntity.receiveDate=[NSDate date];
            
            [messageEntity didSave];
            
            RectangleChat* rectChat=[xmpp fetchRectangleChatFromJid:roomId isGroup:YES];
            
            if(rectChat==nil){
                [xmpp newRectangleMessage:roomId name:@"" content:msg contentType:rectangleChatContentType isGroup:YES createrJid:senderUser];
                [xmpp saveContext];
                rectChat=[xmpp fetchRectangleChatFromJid:roomId isGroup:YES];
            }
            
            rectChat.updateDate=[NSDate date];
            
            if ([ subject isEqualToString:@"quitgroup"]){
                rectChat.content=@"群组已经被解散";
                rectChat.noReadMsgNumber=[NSNumber numberWithInt:0];
                rectChat.isQuit=[NSNumber numberWithBool:YES];
            }
            else if ([ subject isEqualToString:@"quitperson"]) {
                rectChat.content=[NSString stringWithFormat:@"%@已经退出群组",[sender myNickname]];
            }
            else if([subject isEqualToString:@"killperson"]){
                rectChat.content=@"你已被请出群组";
                rectChat.noReadMsgNumber=[NSNumber numberWithInt:0];
                rectChat.isQuit=[NSNumber numberWithBool:YES];
            }
            else{
                rectChat.content=msg;
                int noReadMsgNumber=[rectChat.noReadMsgNumber intValue]+1;
                rectChat.noReadMsgNumber=[NSNumber numberWithInt:noReadMsgNumber];
            }
            rectChat.contentType=[NSNumber numberWithInt:rectangleChatContentType];

            [rectChat didSave];
            
            [MessageRecord createModuleBadge:@"com.foss.chat" num: [XMPPSqlManager getMessageCount]];

            
            if ([ subject isEqualToString:@"quitgroup"]){
                [self delayRemoveNewRoom:roomId];
            }
            else if([subject isEqualToString:@"killperson"]){
                ChatLogic* logic=[[ChatLogic alloc] init];
                logic.roomJID=roomId;
                [logic sendRoomQuitAction:roomId isMyGroup:NO];
                logic=nil;
                [self performSelector:@selector(delayRemoveNewRoom:) withObject:roomId afterDelay:2.0f];

            }
            
        }
    }
    
}


@end

//
//  VoiceUploadManager.m
//  bsl
//
//  Created by 肖昶 on 13-10-11.
//
//

#import "VoiceUploadManager.h"

#import "HTTPRequest.h"
#import "RoomService.h"
#import "XMPPRoom.h"
#import "JSONKit.h"
#import "ServerAPI.h"


static VoiceUploadManager* instance=nil;

@interface VoiceObj()
-(void)startNew;
-(void)startExist;
-(void)cancel;
-(void)callApi;
-(void)downloadVoiceFile:(NSString*)fileId;
-(void)finishAndSendXmpp:(NSString*)fileId;
-(void)failed;
-(void)finishDownloaded;
-(void)failedDownloaded;
@end

@interface VoiceUploadManager()
-(NSString*)juingNewId;
@end

@implementation VoiceObj

- (void)dealloc{
}

-(void)startNew{

    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    @autoreleasepool {
        //新建消息的entity
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MessageEntity" inManagedObjectContext:appDelegate.xmpp.managedObjectContext];
        [newManagedObject setValue:self.uqID forKey:@"uqID"];
        [newManagedObject setValue:self.urlVoiceFile forKey:@"content"];
        [newManagedObject setValue:@"voice" forKey:@"type"];
        [newManagedObject setValue:[NSNumber numberWithInt:0] forKey:@"statue"];
        [newManagedObject setValue:[NSDate date] forKey:@"sendDate"];
        [newManagedObject setValue:self.messageId forKey:@"messageId"];
        [newManagedObject setValue:self.messageId forKey:@"receiveUser"];
        [newManagedObject setValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare] forKey:@"sendUser"];
        [appDelegate.xmpp newRectangleMessage:self.messageId name:self.name content:@"" contentType:RectangleChatContentTypeVoice isGroup:self.isGroup createrJid:nil];
        [appDelegate.xmpp saveContext];
    }

    [self callApi];
}

-(void)startExist{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    MessageEntity* entity=[appDelegate.xmpp fetchMessageFromUqID:self.uqID messageId:self.messageId];
    if(entity!=nil){
        entity.statue=[NSNumber numberWithInt:0];
        [appDelegate.xmpp saveContext];
    }
    [self callApi];

}


-(void)cancel{
    [request cancel];
}

-(void)callApi{
    NSString* token=[[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    NSURL *requestURL = [NSURL URLWithString:[kFileUploadUrl stringByAppendingFormat:@"?sessionKey=%@&&appKey=%@",token,kAPPKey]];
    
    request=[FormDataRequest requestWithURL:requestURL];
    __block FormDataRequest* requestT=(FormDataRequest*)request;
    requestT.timeOutSeconds=10.0f;
    requestT.persistentConnectionTimeoutSeconds=10.0f;
    
    __block VoiceObj* objSelf=self;
    @autoreleasepool {
        
        NSData* fileData = [[NSData alloc] initWithContentsOfFile:self.urlVoiceFile];
        [requestT setData:fileData forKey:@"file"];
        fileData=nil;
    }
    
    [request setCompletionBlock:^{
        
        NSDictionary *dict = [[requestT responseString] objectFromJSONString];
        NSString *fileId = [dict valueForKey:@"id"];
        if(![fileId isKindOfClass:[NSString class]] || [fileId length]<1)
            [objSelf failed];
        else
            [objSelf finishAndSendXmpp:fileId];
    }];
    
    [request setFailedBlock:^{
        [objSelf failed];

    }];
    
    [request startAsynchronous];

}

-(void)downloadVoiceFile:(NSString*)fileId{
    NSString *url = [ServerAPI urlForAttachmentId:fileId];
    url=[url stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],kAPPKey];

    request = [HTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeOutSeconds=10.0f;
    request.persistentConnectionTimeoutSeconds=10.0f;
    [request setDownloadDestinationPath:self.urlVoiceFile];
    __block VoiceObj* objSelf=self;
    
    [request setCompletionBlock:^{
        
        FILE* fp=fopen([objSelf.urlVoiceFile UTF8String], "rb");
        if(fp==nil){
            [objSelf failedDownloaded];
            return ;
        }
        fseek(fp, 0, SEEK_END);
        long count=ftell(fp);
        fclose(fp);
        if(count<1024){
            [objSelf failedDownloaded];
            return ;

        }
        
        [objSelf finishDownloaded];
        
    }];
    
    [request setFailedBlock:^{
        [objSelf failedDownloaded];
    }];
    
    [request startAsynchronous];
    
}

-(void)finishAndSendXmpp:(NSString*)fileId{
    
    XMPPRoom *room=nil;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    if(self.isGroup){
        room=[[appDelegate xmpp].roomService findRoomByJid:self.messageId];
        if(room!=nil && !room.isJoined){
            [self failed];
            return;
        }
    }

    
    //拼写xml格式的xmpp消息
    @autoreleasepool {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:fileId];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message" ];
        [message addAttributeWithName:@"uqID" stringValue:self.uqID];
        
        if(!self.isGroup){
            
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:self.messageId];
            [message addChild:body];
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"voice"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        else{
            [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:[[room roomJID] full]];
            [message addChild:body];
            
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"voice"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        
        //发送消息
        [appDelegate.xmpp.xmppStream sendElement:message];
    }
    MessageEntity* entity=[appDelegate.xmpp fetchMessageFromUqID:self.uqID messageId:self.messageId];
    if(entity!=nil){
        entity.statue=[NSNumber numberWithInt:1];
        [appDelegate.xmpp saveContext];
    }
    
    [self.delegate performSelector:@selector(removeVoiceObj:finish:) withObject:self withObject:[NSNumber numberWithBool:YES]];

    [self cancel];
}

-(void)failed{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    MessageEntity* entity=[appDelegate.xmpp fetchMessageFromUqID:self.uqID messageId:self.messageId];
    if(entity!=nil){
        entity.statue=[NSNumber numberWithInt:-1];
        [appDelegate.xmpp saveContext];
    }
    [self cancel];
    [self.delegate performSelector:@selector(removeVoiceObj:finish:) withObject:self withObject:[NSNumber numberWithBool:NO]];
}

-(void)finishDownloaded{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    MessageEntity* entity=[appDelegate.xmpp fetchMessageFromUqID:self.uqID messageId:self.messageId];
    if(entity!=nil){
        entity.statue=[NSNumber numberWithInt:1];
        entity.content=self.urlVoiceFile;
        [appDelegate.xmpp saveContext];
    }
    [self.delegate performSelector:@selector(removeDownloadVoiceObj:finish:) withObject:self withObject:[NSNumber numberWithBool:YES]];
    [self cancel];

}

-(void)failedDownloaded{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    MessageEntity* entity=[appDelegate.xmpp fetchMessageFromUqID:self.uqID messageId:self.messageId];
    if(entity!=nil){
        entity.statue=[NSNumber numberWithInt:-1];
        [appDelegate.xmpp saveContext];
    }
    [self.delegate performSelector:@selector(removeDownloadVoiceObj:finish:) withObject:self withObject:[NSNumber numberWithBool:NO]];
    [self cancel];

}

@end

@implementation VoiceUploadManager

+(VoiceUploadManager*)sharedInstance{
    if(instance==nil)
        instance=[[VoiceUploadManager alloc] init];
    return instance;
}

-(id)init{
    self=[super init];
    array=[[NSMutableArray alloc] initWithCapacity:2];
    return self;
}

-(void)cance{
    for(VoiceObj* obj in array){
        [obj cancel];
    }
    [array removeAllObjects];
}

-(NSString*)juingNewId{
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
}


-(BOOL)sendVoice:(NSString*)urlVoiceFile messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name uqId:(NSString*)uqID{
    if(isGroup){
        XMPPRoom *room=[[ShareAppDelegate xmpp].roomService findRoomByJid:messageId];
        if(room!=nil && !room.isJoined)return NO;
    }
    BOOL createNew=NO;
    if([uqID length]<1){
        uqID=[self juingNewId];
        createNew=YES;
    }
    VoiceObj * obj=[[VoiceObj alloc] init];
    obj.delegate=self;
    obj.uqID=uqID;
    obj.urlVoiceFile=urlVoiceFile;
    obj.messageId=messageId;
    obj.isGroup=isGroup;
    obj.name=name;
    
    if(createNew)
        [obj startNew];
    else
        [obj startExist];
    
    [array addObject:obj];
    obj=nil;;
    return YES;
}

-(void)receiveVoice:(NSString*)content uqId:(NSString*)uqId messageId:(NSString*)messageId isGroup:(BOOL)isGroup{
    if([uqId length]<1)
        uqId=content;
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    MessageEntity* entity=[appDelegate.xmpp fetchMessageFromUqID:uqId messageId:messageId];
    if(entity!=nil){
        entity.statue=[NSNumber numberWithInt:0];
        [appDelegate.xmpp saveContext];
    }
    
    VoiceObj * obj=[[VoiceObj alloc] init];
    obj.delegate=self;
    obj.uqID=uqId;
    obj.messageId=messageId;
    obj.isGroup=isGroup;
    obj.urlVoiceFile=[self downloadVoiceFile:content];

    
    [obj downloadVoiceFile:content];
    
    [array addObject:obj];
    obj=nil;
    
}


-(NSString*)downloadVoiceFile:(NSString*)uqID{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex: 0];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    docDir=[docDir stringByAppendingPathComponent:[[[appDelegate xmpp].xmppStream myJID]bare]];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:docDir]){
        [fileManager createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [docDir stringByAppendingPathComponent: [NSString stringWithFormat: @"receiver_%@.caf", uqID]];
}


#pragma mark delegate
-(void)removeVoiceObj:(VoiceObj*)obj finish:(NSNumber*)finish{
    if([self.delegate respondsToSelector:@selector(voiceUploadFinish:finish:)])
        [self.delegate voiceUploadFinish:obj.uqID finish:[finish boolValue]];
    [array removeObject:obj];
}

-(void)removeDownloadVoiceObj:(VoiceObj*)obj finish:(NSNumber*)finish{
    if([self.delegate respondsToSelector:@selector(voiceDownloadFinish:finish:)])
        [self.delegate voiceDownloadFinish:obj.uqID finish:[finish boolValue]];
    [array removeObject:obj];

}

@end

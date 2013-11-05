//
//  AttachMents.m
//  bsl
//
//  Created by zhoujun on 13-11-5.
//
//

#import "AttachMents.h"
#import "ServerAPI.h"
#import "ASIHTTPRequest.h"
@implementation AttachMents

@dynamic announceId;
@dynamic fileId;
@dynamic fileName;
@dynamic fileSize;
@dynamic filePath;
-(void)downloadFile:(NSString*)attachId
{
    NSString *url = [ServerAPI urlForAttachmentId:attachId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *filePath = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"attachmens"];
    BOOL flag = YES;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath isDirectory:&flag])
    {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [request setDownloadDestinationPath:filePath];
    [request setTimeOutSeconds:30.0];
    [request setPersistentConnectionTimeoutSeconds:30.0];
    [request setCompletionBlock:^{
        NSLog(@"download successfully");
        self.filePath = [@"attachmens" stringByAppendingPathComponent:self.fileName];
        [self save];
        
    }];
    [request setFailedBlock:^{
        NSLog(@"download failed");
    }];
    [request startAsynchronous];
}
@end

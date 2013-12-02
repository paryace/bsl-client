//
//  AttachMents.m
//  bsl
//
//  Created by zhoujun on 13-11-5.
//
//

#import "AttachMents.h"
#import "ServerAPI.h"
#import "SVProgressHUD.h"
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
    if([[self.fileName lowercaseString] hasSuffix:@"pdf"])
    {
        attachId = [NSString stringWithFormat:@"%@.pdf",attachId];
    }
    else if([[self.fileName lowercaseString] hasSuffix:@"txt"])
    {
        attachId = [NSString stringWithFormat:@"%@.txt",attachId];
    }
    NSString *filePath = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"attachmens"];
    BOOL flag = YES;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath isDirectory:&flag])
    {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [filePath stringByAppendingPathComponent:attachId];
    [request setDownloadDestinationPath:filePath];
    [request setDidFinishSelector:@selector(finish:)];
    [request setDidFailSelector:@selector(failed:)];
    request.delegate = self;
    [request startAsynchronous];
}
-(void)finish:(ASIHTTPRequest *)request
{
    NSLog(@"下载成功");
}

-(void)failed:(ASIHTTPRequest *)request
{
    NSLog(@"下载失败");
    NSLog(@"%d",[request responseStatusCode]);
}
-(NSString *)downloadFileForPath:(NSString*)attachId
{
    if(![SVProgressHUD isVisible])
    {
        [SVProgressHUD showWithStatus:@"文件下载中" maskType:SVProgressHUDMaskTypeBlack];
    }
    NSString *url = [ServerAPI urlForAttachmentId:attachId];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    if([[self.fileName lowercaseString] hasSuffix:@"pdf"])
    {
        attachId = [NSString stringWithFormat:@"%@.pdf",attachId];
    }
    else if([[self.fileName lowercaseString] hasSuffix:@"txt"])
    {
        attachId = [NSString stringWithFormat:@"%@.txt",attachId];
    }
    NSString *filePath = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"attachmens"];
    BOOL flag = YES;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath isDirectory:&flag])
    {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [filePath stringByAppendingPathComponent:attachId];
    [request setDownloadDestinationPath:filePath];
    [request startSynchronous];
    NSError *error;
    error = [request error];
    if(error)
    {
        if([SVProgressHUD isVisible])
        {
            [SVProgressHUD dismiss];
        }
        NSLog(@"下载失败");
        NSLog(@"%@",error);
        return @"";
    }
    else
    {
        if([SVProgressHUD isVisible])
        {
            [SVProgressHUD dismiss];
        }
        NSLog(@"下载成功");
        return [request downloadDestinationPath];
    }

}

@end

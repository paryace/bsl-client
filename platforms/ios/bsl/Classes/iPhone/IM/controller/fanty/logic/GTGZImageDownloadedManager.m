//
//  GTGZImageDownloadedManager.m
//  GTGZLibrary
//
//  Created by fanty on 13-4-22.
//  Copyright (c) 2013年 fanty. All rights reserved.
//

#import "GTGZImageDownloadedManager.h"
#import "ASIHTTPRequest.h"
#import "AsyncImageView.h"

#define  IMAGE_HTTP_TIME_OUT     8
static GTGZImageDownloadedManager* instance=nil;

@interface GTGZImageDownloadModel:NSObject{
    NSTimer* timer;
}

@property(nonatomic,assign) CGSize size;
@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) UIImage* image;
@property(nonatomic,assign) BOOL downloaded;

-(void)checkFileAndDownload;
-(void)delayLoadImage;
-(void)checkFile;
+(NSString*)pathByUrl:(NSURL*)url;


@end

@interface GTGZImageDownloadedManager()
@property(nonatomic,strong) NSString* saveImagePath;

@end

@implementation GTGZImageDownloadModel

@synthesize url;
@synthesize size;
@synthesize image;
@synthesize downloaded;

-(id)init{
    self=[super init];
    self.size=CGSizeMake(255.0f, 255.0f);
    return self;
}

-(void)dealloc{
    self.url=nil;
    self.image=nil;
}

-(void)delayLoadImage{
    [timer invalidate];
    timer=nil;
    self.downloaded=YES;
    
    if(image==nil){
        [self checkFile];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationImageLoadingFinish object:self.url];
    
}

+(NSString*)pathByUrl:(NSURL*)nsUrl{
    return [[GTGZImageDownloadedManager sharedInstance].saveImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.png",[nsUrl host],[[nsUrl path] stringByReplacingOccurrencesOfString:@"/" withString:@""] ]  ];

}

-(void)checkFileAndDownload{
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.url]){
        if(timer==nil)
            timer=[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(delayLoadImage) userInfo:nil repeats:NO];
        return;
    }
    
    NSURL* nsUrl=[NSURL URLWithString:self.url];
    NSString* path=[GTGZImageDownloadModel pathByUrl:nsUrl  ];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        //delay to call
        if(timer==nil)
            timer=[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(delayLoadImage) userInfo:nil repeats:NO];
        
    }
    else{
        
        ASIHTTPRequest* request=[ASIHTTPRequest requestWithURL:nsUrl];

        request.timeOutSeconds=8.0f;
        request.persistentConnectionTimeoutSeconds=8.0f;
        [request setDownloadDestinationPath :path];
        [request setCompletionBlock:^{
            self.downloaded=YES;
            //notification
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationImageLoadingFinish object:self.url];
        }];
        [request setFailedBlock:^{
            self.downloaded=YES;
            self.image=nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationImageLoadingFinish object:self.url];
        }];
        [request startAsynchronous ];
    }
    
}

-(void)checkFile{
    if(self.image!=nil)return;
    @autoreleasepool {
        if([[NSFileManager defaultManager] fileExistsAtPath:self.url]){
            UIImage* img=[[UIImage alloc] initWithContentsOfFile:self.url];
            self.image=img;
            img=nil;
            
            if(self.image!=nil){
                if(size.width>0 && size.height>0){
                    CGSize _size=self.image.size;
                    if((_size.width>size.width && _size.height>size.height) || (_size.width<60.0f && _size.height<60.0f)){
                        self.image=[AsyncImageView imageWithThumbnail:self.image size:self.size];
                    }
                }
            }
            
        }
        else{
            NSURL* nsUrl=[NSURL URLWithString:self.url];
            NSString* path=[GTGZImageDownloadModel pathByUrl:nsUrl];
            
            NSData* data=[[NSData alloc] initWithContentsOfFile:path];
            UIImage* img=[[UIImage alloc] initWithData:data];
            data=nil;
            self.image=img;
            img=nil;
            
            if(self.image==nil){
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            else{
                if(size.width>0 && size.height>0){
                    CGSize _size=self.image.size;
                    if((_size.width>size.width && _size.height>size.height) || (_size.width<60.0f && _size.height<60.0f)){
                        self.image=[AsyncImageView imageWithThumbnail:self.image size:self.size];
                    }
                }
            }
        }
    }
}

@end



@implementation GTGZImageDownloadedManager
@synthesize saveImagePath;
@synthesize delegate;

+(GTGZImageDownloadedManager*)sharedInstance{
    if(instance==nil)
        instance=[[GTGZImageDownloadedManager alloc] init];
    return instance;
}

-(id)init{
    self=[super init];
    
    NSString* imageRoot=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    imageRoot=[imageRoot stringByAppendingPathComponent:@"images"];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:imageRoot]){
        [fileManager createDirectoryAtPath:imageRoot withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.saveImagePath=imageRoot;
    list=[[NSMutableArray alloc] initWithCapacity:3];
    return self;
}


-(void)dealloc{
    self.saveImagePath=nil;
}

-(UIImage*)appendUrl:(NSString*)url size:(CGSize)size{
    if([url length]<1)return nil;
    
    for(GTGZImageDownloadModel* model in list){
        if([model.url isEqualToString:url]){
            if(model.image!=nil){
                return model.image;
            }
            else{
                [model checkFile];
                if(model.image!=nil){
                    return model.image;
                }
            }
            if(model.downloaded && model.image==nil){
                model.downloaded=NO;
                [model checkFileAndDownload];
                
            }
            return nil;
        }
    }
    GTGZImageDownloadModel* model =[[GTGZImageDownloadModel alloc] init];
    model.size=size;
    model.url=url;
    [model checkFileAndDownload];
    [list addObject:model];

    model=nil;
    return nil;
}


-(UIImage*)get:(NSString*)url{
    for(GTGZImageDownloadModel* model in list){
        if([model.url isEqualToString:url]){
            [model checkFile];
            return model.image;
        }
    }
    return nil;
}

-(void)removeAll{
    [list removeAllObjects];
}

-(BOOL)checkImageIsDownloadedByUrl:(NSString*)url{
    if([url length]<1)return YES;
    for(GTGZImageDownloadModel* model in list){
        if([model.url isEqualToString:url]){
            return model.downloaded;
        }
    }
    return YES;
}


-(UIImage*)originImageByUrl:(NSString*)url{
    if([[NSFileManager defaultManager] fileExistsAtPath:url]){
        return [[UIImage alloc] initWithContentsOfFile:url];
    }
    else{
        return [[UIImage alloc] initWithContentsOfFile:[GTGZImageDownloadModel pathByUrl:[NSURL URLWithString:url]]];
    }
}


@end

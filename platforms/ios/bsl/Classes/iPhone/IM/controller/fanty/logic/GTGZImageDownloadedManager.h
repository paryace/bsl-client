//
//  GTGZImageDownloadedManager.h
//  GTGZLibrary
//
//  Created by fanty on 13-4-22.
//  Copyright (c) 2013年 fanty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;

#define NotificationImageLoadingFinish    @"gtgz_image_finish"

@protocol GTGZImageDownloadedManagerDelegate <NSObject>


-(ASIHTTPRequest*)imageDownloadRequest:(NSURL*)url;
@end

/*！
 @class GTGZImageManager
 @abstract  image download and show manager
 */
@interface GTGZImageDownloadedManager : NSObject{
    NSMutableArray* list;
}

@property(nonatomic,weak) id<GTGZImageDownloadedManagerDelegate> delegate;
/*
 @return the shared instance
 */
+(GTGZImageDownloadedManager*)sharedInstance;

/*
 @property url:          download url
 @property size          image size
 @check the image is downloaded. if yes return UIImage  if not then download
 */
-(UIImage*)appendUrl:(NSString*)url size:(CGSize)size;

/*
 @property url:          download url
 @get the UIImage from url
 */
-(UIImage*)get:(NSString*)url;

/*
 @remove UIImage
 */
-(void)removeAll;


/*
 @property url:   download url
 @property size          image size
 @check image is downloaded
 */
-(BOOL)checkImageIsDownloadedByUrl:(NSString*)url;

-(UIImage*)originImageByUrl:(NSString*)url;

-(NSString*)originPathByUrl:(NSString*)url;

@end

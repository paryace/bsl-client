//
//  ImageDownloadedView.h
//  cube-ios
//
//  Created by 肖昶 on 13-9-15.
//
//

#import "AsyncImageView.h"

typedef enum _ImageViewDownloadedStatus {
	ImageViewDownloadedStatusNone = 0,
    ImageViewDownloadedStatusDownloading,
    ImageViewDownloadedStatusFinish,
    ImageViewDownloadedStatusFail,
} ImageViewDownloadedStatus;


@interface ImageDownloadedView : UIImageView{
    ImageViewDownloadedStatus status;
    
    UIImageView* loadingView;
    
    UIActivityIndicatorView* activityView;
}

@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) NSString* loadingImageName;
@property(nonatomic,assign) BOOL showLoading;
@property(nonatomic,readonly) ImageViewDownloadedStatus status;

@end

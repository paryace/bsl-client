//
//  ImageDownloadedView.m
//  cube-ios
//
//  Created by 肖昶 on 13-9-15.
//
//

#import "ImageDownloadedView.h"
#import "GTGZImageDownloadedManager.h"

/*
 
 static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
 float ovalHeight){
 float fw, fh;
 
 if (ovalWidth == 0 || ovalHeight == 0){
 CGContextAddRect(context, rect);
 return;
 }
 
 CGContextSaveGState(context);
 CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
 CGContextScaleCTM(context, ovalWidth, ovalHeight);
 fw = CGRectGetWidth(rect) / ovalWidth;
 fh = CGRectGetHeight(rect) / ovalHeight;
 
 CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
 CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
 CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
 CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
 CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
 
 CGContextClosePath(context);
 CGContextRestoreGState(context);
 }
 
 + (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r{
 // the size of CGContextRef
 int w = size.width;
 int h = size.height;
 
 UIImage *img = image;
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
 CGRect rect = CGRectMake(0, 0, w, h);
 
 CGContextBeginPath(context);
 addRoundedRectToPath(context, rect, r, r);
 CGContextClosePath(context);
 CGContextClip(context);
 CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
 CGImageRef imageMasked = CGBitmapContextCreateImage(context);
 img = [UIImage imageWithCGImage:imageMasked];
 
 CGContextRelease(context);
 CGColorSpaceRelease(colorSpace);
 CGImageRelease(imageMasked);
 
 return img;
 }
 
 */



@interface ImageDownloadedView()

-(void)imageLoadingFinish:(NSNotification*)notification;
@end


@implementation ImageDownloadedView

@synthesize url;
@synthesize loadingImageName;
@synthesize status;
-(id)init{
    self=[super init];
    if(self){
        status=ImageViewDownloadedStatusNone;
        self.loadingImageName=@"NoHeaderImge.png";
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        status=ImageViewDownloadedStatusNone;
        self.loadingImageName=@"NoHeaderImge.png";
    }
    return self;
    
}

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        status=ImageViewDownloadedStatusNone;
        self.loadingImageName=@"NoHeaderImge.png";
    }
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setUrl:(NSString *)value{
    if([self.url isEqualToString:value])return;
    
    status=ImageViewDownloadedStatusNone;

    url=value;
    
    self.image=nil;
    
    if([value length]<1){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        return;
    }
    
    //start download
    
    self.image=[[GTGZImageDownloadedManager sharedInstance] appendUrl:self.url size:self.frame.size];
    
    if(self.image==nil){
        if([[GTGZImageDownloadedManager sharedInstance] checkImageIsDownloadedByUrl:self.url]){
            status=ImageViewDownloadedStatusFail;
        }
        else{
            status=ImageViewDownloadedStatusDownloading;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoadingFinish:) name:NotificationImageLoadingFinish object:nil];
        }
    }
    else{
        status=ImageViewDownloadedStatusFinish;
    }
}

-(void)imageLoadingFinish:(NSNotification*)notification{
    if(self.status!=ImageViewDownloadedStatusFinish){
        NSString* __url=notification.object;
        if([self.url isEqualToString:__url]){
            UIImage* img=[[GTGZImageDownloadedManager sharedInstance] get:self.url];
            if(img!=nil){
                status=ImageViewDownloadedStatusFinish;
                self.image=img;
                [[NSNotificationCenter defaultCenter] removeObserver:self];
            }
            else{
                status=ImageViewDownloadedStatusFail;
            }
            [self layoutSubviews];

        }
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(status!=ImageViewDownloadedStatusFinish){
        
        if(self.showLoading){
            if(activityView==nil){
                activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityView.frame=CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
                [self addSubview:activityView];
            }
            [activityView startAnimating];
            [self sendSubviewToBack:activityView];
            CGRect rect=activityView.frame;
            rect.origin.x=(self.frame.size.width-rect.size.width)*0.5f;
            rect.origin.y=(self.frame.size.height-rect.size.height)*0.5f;
            activityView.frame=rect;
        }        
        if(loadingView==nil){
            loadingView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:self.loadingImageName]];
            loadingView.clipsToBounds=YES;
            [self addSubview:loadingView];
        }
        [self sendSubviewToBack:loadingView];
        loadingView.frame=self.bounds;
    }
    else{
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        activityView=nil;
        [loadingView removeFromSuperview];
        loadingView=nil;
    }
    
}

-(void)setLoadingImageName:(NSString *)value{
    loadingImageName=value;
    if(loadingView!=nil)
        loadingView.image=[UIImage imageNamed:value];
    [self layoutSubviews];
}


@end


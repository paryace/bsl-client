//
//  ImageScroller.m
//  cube-ios
//
//  Created by apple2310 on 13-9-10.
//
//

#import "ImageScroller.h"
#import "AsyncImageView.h"

#import "GTGZImageDownloadedManager.h"
#import <QuartzCore/QuartzCore.h>

@interface ImageScroller()<UIScrollViewDelegate>
- (void)handleSingleTap:(UITapGestureRecognizer*)recognizer;
@end

@implementation ImageScroller

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled=YES;
        
        self.backgroundColor=[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.75f];

        frame=self.bounds;
        frame.origin.y=20.0f;
        frame.size.height-=20.0f;
        
        scrollView = [[UIScrollView alloc] initWithFrame:frame];
        
        scrollView.backgroundColor=[UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1.0f;
        scrollView.maximumZoomScale = 1.7f;

        UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapOne.numberOfTapsRequired = 1;
        [scrollView addGestureRecognizer:singleTapOne];
        
        
        imageView=[[UIImageView alloc] initWithFrame:scrollView.bounds];
        imageView.userInteractionEnabled=NO;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
        
        [self addSubview:scrollView];
        

    }
    return self;
}


-(void)showInView:(UIView*)view{
    [view addSubview:self];
    
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [imageView.layer addAnimation:animation forKey:nil];

    
    self.alpha=0.0f;
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.alpha=1.0f;
    } completion:^(BOOL finish){
        
    }];

    
}

-(void)showImage:(NSString*)url{
    imageView.image=[[GTGZImageDownloadedManager sharedInstance] originImageByUrl:url];
}


- (void)handleSingleTap:(UITapGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateRecognized){
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.alpha=0.0f;
        } completion:^(BOOL finish){
            
            [self removeFromSuperview];
        }];


    }
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)_scrollView{
    return imageView;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)_scrollView{
    if(_scrollView.zoomScale==1.0f){
        scrollView.contentOffset=CGPointZero;
        scrollView.contentSize=scrollView.frame.size;

        imageView.frame=scrollView.bounds;
    }
    else{
        CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?
        
        (_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5 : 0.0;
        
        CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?
        
        (_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5 : 0.0;
        
        imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX,
                                          
                                          _scrollView.contentSize.height * 0.5 + offsetY);
    }
    
}

@end

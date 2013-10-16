//
//  IconButton.m
//  Cube-iOS
//
//  Created by chen shaomou on 12/7/12.
//
//

#import "IconButton.h"
#import <QuartzCore/QuartzCore.h>
#include <stdlib.h>
#import "MessageRecord.h"
#import "UIImage+Antialiase.h"

#define kButtonDefaultRect CGRectMake(0, 0, 85, 113)
#define kIconImageView CGRectMake(6, 14, 72, 67)
#define kUpdateableImageView CGRectMake(6, 14, 38, 38)
#define kIconLabel CGRectMake(0, 92, 85, 16)
#define kActionButton CGRectMake(0, 0, 85, 108)
#define kRemoveButton CGRectMake(self.frame.size.width-30, 0, 35, 35)
#define kDownloadMaskView CGRectMake(0, 0, 85, 108)
#define kDownloadProgressView CGRectMake(14, 70, 56, 11)

@implementation IconButton

@synthesize stauts,delegate,identifier,tag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self registerLongPress];
    }
    return self;
}

-(void)defaultSet
{
    self.frame=kButtonDefaultRect;
    self.iconImageView.frame=kIconImageView;
    self.updateableImageView.frame=kUpdateableImageView;
    self.iconLabel.frame=kIconLabel;
    self.actionButton.frame=kActionButton;
    self.removeButton.frame=kRemoveButton;
    self.downloadMaskView.frame=kDownloadMaskView;
    self.downloadProgressView.frame=kDownloadProgressView;
}

- (void)transformFixIcon:(IconLeftStatus)curStatus
{
    
}

- (void) transformWithWidth:(NSInteger)aWidth andHeight:(NSInteger)aHeight
{
    //???‰æ?º©Â∞??Â±?//    float hRadio=(float)aWidth/85;
//    float vRadio=(float)aHeight/108;
    float hRadio=(float)aWidth/85;
    float vRadio=(float)aHeight/113;
    self.iconImageView.frame=CGRectMake(self.iconImageView.frame.origin.x*hRadio, self.iconImageView.frame.origin.y*vRadio, self.iconImageView.frame.size.width*hRadio, self.iconImageView.frame.size.height*vRadio);
    self.updateableImageView.frame=CGRectMake(self.updateableImageView.frame.origin.x*hRadio, self.updateableImageView.frame.origin.y*vRadio, self.updateableImageView.frame.size.width*hRadio, self.updateableImageView.frame.size.height*vRadio);
    self.iconLabel.frame=CGRectMake(self.iconLabel.frame.origin.x*hRadio, self.iconLabel.frame.origin.y*vRadio, self.iconLabel.frame.size.width*hRadio, self.iconLabel.frame.size.height*vRadio);
    self.removeButton.frame=CGRectMake(self.removeButton.frame.origin.x*hRadio, self.removeButton.frame.origin.y*vRadio, self.removeButton.frame.size.width*hRadio, self.removeButton.frame.size.height*vRadio);
     self.downloadProgressView.frame=CGRectMake(self.downloadProgressView.frame.origin.x*hRadio, self.downloadProgressView.frame.origin.y*vRadio, self.downloadProgressView.frame.size.width*hRadio, self.downloadProgressView.frame.size.height*vRadio);
     self.downloadMaskView.frame=CGRectMake(self.downloadMaskView.frame.origin.x*hRadio, self.downloadMaskView.frame.origin.y*vRadio, self.downloadMaskView.frame.size.width*hRadio, self.downloadMaskView.frame.size.height*vRadio);
     self.removeButton.frame=CGRectMake(self.removeButton.frame.origin.x*hRadio, self.removeButton.frame.origin.y*vRadio, self.removeButton.frame.size.width*hRadio, self.removeButton.frame.size.height*vRadio);
    self.iconLabel.textColor=[UIColor grayColor];
    self.iconLabel.font=[UIFont systemFontOfSize:11];
    
    
    if (self.leftImageView) {
        self.leftImageView.frame=CGRectMake(self.leftImageView.frame.origin.x*hRadio, self.leftImageView.frame.origin.y*vRadio, self.leftImageView.frame.size.width*hRadio, self.leftImageView.frame.size.height*vRadio);
    }
    
    
    [self.actionButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//    [self.actionButton removeGestureRecognizer:nil];
    if (!_isShowMode) {
        [self.actionButton addTarget:self action:@selector(checkDetial:) forControlEvents:UIControlEventTouchUpInside];
    }
    //    [self.actionButton :];
    
}

- (void) checkDetial:(id)sender
{
    NSLog(@"pressed");
    UIButton *tempButton=(UIButton*)sender;
    tempButton.tag=self.tag;
    [self removeBadge];
    [MessageRecord dismissModuleBadge:self.identifier];
    [self.delegate launch:self.tag identifier:self.identifier];
}

-(id)initWithModule:(CubeModule *)module stauts:(int)staut delegate:(id<IconButtonDelegate>)delegate_{

    self =  [self initWithIdentifier:module.identifier iconName:module.name IconImageUrl:module.iconUrl iconStauts:staut delegate:delegate_];
    
    if(self){
        
        [self observerDownload:module];
    
    }
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier_ iconName:(NSString *)iconName IconImageUrl:(NSString *)iconImageUrl iconStauts:(int)staut delegate:(id<IconButtonDelegate>)delegate_{
    
    self = [self initWithFrame:CGRectMake(0, 0, 85, 108)];
    
    self.identifier = identifier_;
    
    self.delegate = delegate_;
    
    self.stauts = staut;
    
    self.isInEditingMode = NO;
    
    //icon image
    _iconImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(6, 14, 72, 72)];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *token =  [defaults objectForKey:@"token"];
    NSString* url = [iconImageUrl stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",token,kAPPKey];
    
    [_iconImageView loadImageWithURLString:url];
    
    [self addSubview:_iconImageView];
    
    //bage image
    
    UIImage *updateableImage = [UIImage imageNamed:@"Module_Action_Update@2x.png"];
    
    _updateableImageView = [[UIImageView alloc] initWithImage:updateableImage highlightedImage:updateableImage];
    
    [_updateableImageView setFrame:CGRectMake(0, 0, 38, 38)];
    
    if(stauts != IconButtonStautsNeedUpdate){
        
        [_updateableImageView setHidden:YES];
        
    }
    
    [self addSubview:_updateableImageView];
    
    //icon lable
    _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 92, 85, 16)];
    _iconLabel.minimumFontSize=5;
    _iconLabel.adjustsFontSizeToFitWidth=TRUE;
    [_iconLabel setText:iconName];
    
    [_iconLabel setBackgroundColor:[UIColor clearColor]];
    
    [_iconLabel setTextColor:[UIColor whiteColor]];
    
    [_iconLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:_iconLabel];
    
    //action button
    _actionButton = [[UIButton alloc] initWithFrame:self.frame];
    
    [self addSubview: _actionButton];
    
    [_actionButton setBackgroundColor:[UIColor clearColor]];
    
    [_actionButton addTarget:self action:@selector(didClickActionButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //download mask view
    _downloadMaskView = [[UIView alloc] initWithFrame:self.frame];
    
    //mask view
    UIView *grayMaskView = [[UIView alloc] initWithFrame:CGRectMake(6, 14, 72, 72)];
    [grayMaskView setAlpha:0.9];
    [grayMaskView setBackgroundColor:[UIColor darkGrayColor]];
    
    [_downloadProgressView addSubview:grayMaskView];
    
    
    //process view
    _downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    
    [_downloadProgressView setFrame:CGRectMake(14, 70, 56, 11)];
    
    [_downloadProgressView setProgress:0.0];
    
    [_downloadMaskView addSubview:_downloadProgressView];
    
    [self addSubview:_downloadMaskView];
    
    if(stauts != IconButtonStautsDownloading){
        
        [_downloadMaskView setHidden:YES];
    }
    
    [self addBadge];
    
    //????∂Â?Ê∂???®È???otificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageRevice:) name:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:nil];
    
    
    
    return self;

}


-(void)removeNotification{
    [self removeDownloadObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}


-(void)newMessageRevice:(NSNotification*)notification{
    //remove by fanty   推送暂不更新这时
    /*
    if ([self.identifier isEqualToString:@"com.foss.message.record"]) {
        [self addBadge];
        return;
    }
    
    MessageRecord *record =  (MessageRecord *)notification.object;
    if (self.identifier) {
    if([record.module isEqualToString:self.identifier]){
    
        [self addBadge];
    }
   }
     */
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) enableEditing {
    
    if (self.isInEditingMode == YES)
        return;
    
    // put item in editing mode
    self.isInEditingMode = YES;
    
    // make the remove button visible
    if(stauts == IconButtonStautsUseable || stauts == IconButtonStautsNeedUpdate){
        if (_removeButton == nil) {
            _removeButton = [[UIButton alloc]initWithFrame:kRemoveButton];
            [_removeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
            [_removeButton addTarget:self action:@selector(closeItem:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_removeButton];
        }
        [_removeButton setHidden:NO];
    }    
    
    // start the wiggling animation
    CATransform3D transform;
    transform = CATransform3DMakeRotation(-0.08, 0, 0, 1.0);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.autoreverses = YES;
    animation.duration = 0.1;
    animation.repeatCount = 10000;
    animation.delegate = self;
    [[self layer] addAnimation:animation forKey:@"wiggleAnimation"];
    
    // inform the springboard that the menu items are now editable so that the springboard
    // will place a done button on the navigationbar
    
    
}

- (void) disableEditing {
    [[self layer] removeAllAnimations];
    [_removeButton setHidden:YES];
    self.isInEditingMode = NO;
}

- (void) updateTag:(int) newTag {
    self.tag = newTag;
    _removeButton.tag = newTag;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self removeDownloadObserver];
    
}
- (IBAction)didClickActionButton:(id)sender {
    UIButton *theButton = (UIButton *) sender;
    if(stauts == IconButtonStautsUseable || stauts == IconButtonStautsNeedUpdate || stauts == IconButtonStautsFirmware ){
        [[self delegate] launch:theButton.tag identifier:identifier];
    }
}

-(void)didProgressUpdate:(NSNotification *) notification{

    NSNumber *progress = (NSNumber *)[[notification userInfo] objectForKey:@"newProgress"];
    
    [_downloadProgressView setProgress:[progress floatValue]];
    
}

-(void)observerDownload:(id)observedObj{
    
    [self removeDownloadObserver];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didProgressUpdate:) name:@"module_download_progressupdate" object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDownload:) name:CubeModuleDownloadDidFinishNotification object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDownload:) name:CubeModuleInstallDidFinishNotification object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FailDownload:) name:CubeModuleInstallDidFailNotification object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FailDownload:) name:CubeModuleDownloadDidFailNotification object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownload:) name:CubeModuleDownloadDidStartNotification object:observedObj];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:@"module_badgeCount_change" object:nil];
}

-(void)finishDownload:(NSNotification *) notification{
    [self setStauts:IconButtonStautsUseable];
    [self removeDownloadObserver];
    self.downloadMaskView.hidden = YES;
}

-(void)FailDownload:(NSNotification *) notification{
    [self setStauts:IconButtonStautsUseable];
    [self removeDownloadObserver];
    self.downloadMaskView.hidden = YES;
    self.updateableImageView.hidden = NO;
}

-(void)startDownload:(NSNotification *) notification{
    self.downloadMaskView.hidden = NO;
    self.updateableImageView.hidden = YES;
}

-(void)removeDownloadObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"module_download_progressupdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleInstallDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleInstallDidFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleDownloadDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleDownloadDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleDownloadDidFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"module_badgeCount_change" object:nil];
}


- (IBAction)didClickRemoveButton:(id)sender {
    [[self delegate] removeEnuseableModuleFromSpringboard:self.identifier index:self.tag];
}

- (IBAction)pressActionButtonLong:(id)sender {
    [self enableEditing];
}


-(void)addBadgeWithModuleIdentifier:(NSString *)moduleIdentifier{
    
    int count = [MessageRecord countForModuleIdentifierAtBadge:moduleIdentifier];
    
    if(count > 0){
        if(!_badgeView){
            _badgeView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentTopRight];
        }
        
        NSString *countText = [[NSString alloc] initWithFormat:@"%d", count];
        _badgeView.badgeText = countText;
        countText=nil;
    }else{
    
        [self removeBadge];
    }
}



-(void)addBadge{
    if([@"com.foss.message.record" isEqualToString:self.identifier]){
        [self addAllRecordsBadge];
    }else{
        
        [self addBadgeWithModuleIdentifier:self.identifier];
    }
}

-(void)addAllRecordsBadge{
    
    int count = [MessageRecord countAllAtBadge];
    
    [self addBadgeToIcon:count];
}

-(void)addBadgeToIcon:(int)count{
    
    if(count > 0){
        
        if(!_badgeView){
            
            _badgeView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentTopRight];
            
        }
        
        _badgeView.badgeText = [NSString stringWithFormat:@"%d", count];
    }else{
        
        [self removeBadge];
    }
}



-(void)removeBadge{
    if(_badgeView){
        [_badgeView removeFromSuperview];
        _badgeView=nil;
       // self.badgeView = nil;
    }
}


//Ê≥®Â??øÊ??????
-(void)registerLongPress{
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer*longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressed:)];
    //‰ª£Á?
    //longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    //Â∞??????øÊ∑ª??????ÂÆ???øÊ????????æÈ?
    [self addGestureRecognizer:longPress];
}

//?øÊ?‰∫?ª∂????∞Ê?Ê≥?
- (void) handleLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    //???  ËÆæÁΩÆ?????conButton ‰∏∫Á?Ëæ?®°Âº?    
   [self.delegate enableEditingMode];
}

#pragma mark - Touch

-(void)closeItem:(id)sender
{
    if (delegate) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"确认删除该模块?"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:@"取消", nil];
        alert.tag = 5;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 5  && buttonIndex == 0) {
        [self.delegate removeEnuseableModuleFromSpringboard:self.identifier index:self.tag];
    }

}




@end

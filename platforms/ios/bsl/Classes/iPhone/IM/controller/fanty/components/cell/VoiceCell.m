//
//  VoiceCell.m
//  cube-ios
//
//  Created by apple2310 on 13-9-9.
//
//

#import "VoiceCell.h"
#import "ImageDownloadedView.h"

#define MAX_WIDTH  180.0f

static UIImage* receiveImg=nil;
static UIImage* receiveHLImg=nil;

static UIImage* senderImg=nil;
static UIImage* senderHLImg=nil;

@interface VoiceCell()

@end

@implementation VoiceCell

@synthesize type;
@synthesize status;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        status=-2;
        
        if(receiveImg==nil){
            receiveImg=[UIImage imageNamed:@"VOIPReceiverVoiceNodeBkg.png"];
            receiveImg=[receiveImg stretchableImageWithLeftCapWidth:receiveImg.size.width*0.5f topCapHeight:receiveImg.size.height*0.5f];
        }
        if(receiveHLImg==nil){
            receiveHLImg=[UIImage imageNamed:@"VOIPReceiverVoiceNodeBkgHL.png"];
            receiveHLImg=[receiveHLImg stretchableImageWithLeftCapWidth:receiveHLImg.size.width*0.5f topCapHeight:receiveHLImg.size.height*0.5f];

        }
        if(senderImg==nil){
            senderImg=[UIImage imageNamed:@"VOIPSenderVoiceNodeBkg.png"];
            receiveHLImg=[receiveHLImg stretchableImageWithLeftCapWidth:receiveHLImg.size.width*0.5f topCapHeight:receiveHLImg.size.height*0.5f];

        }
        if(senderHLImg==nil){
            senderHLImg=[UIImage imageNamed:@"VOIPSenderVoiceNodeBkgHL.png"];
            senderHLImg=[senderHLImg stretchableImageWithLeftCapWidth:senderHLImg.size.width*0.5f topCapHeight:senderHLImg.size.height*0.5f];
        }
        
        self.accessoryType=UITableViewCellAccessoryNone;
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        
        
        CGRect rect=CGRectMake(0.0f, 0.0f, 55.0f, 55.0f);

        
        imageView=[[ImageDownloadedView alloc] initWithFrame:rect];
        //        imageView.radius=4.0f;
        imageView.loadingImageName=@"NoHeaderImge.png";
        [self addSubview:imageView];
        
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 15.0f)];
        nameLabel.font=[UIFont systemFontOfSize:11.0f];
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:nameLabel];

        
        button=[UIButton buttonWithType:UIButtonTypeCustom];
        


        rect=button.frame;
        rect.size.width=receiveImg.size.width;
        rect.size.height=50.0f;
        button.frame=rect;

        [self addSubview:button];

        voiceImageView=[[UIImageView alloc] init];
        voiceImageView.animationDuration=1.0f;
        voiceImageView.animationRepeatCount=0;
        [button addSubview:voiceImageView];

        
        dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 20.0f)];
        dateLabel.font=[UIFont systemFontOfSize:12.0f];
        dateLabel.textColor=[UIColor blackColor];
        dateLabel.backgroundColor=[UIColor clearColor];
        dateLabel.adjustsFontSizeToFitWidth=YES;
        [self addSubview:dateLabel];


    }
    return self;
}

-(void)headerUrl:(NSString*)headerUrl{
    
        [imageView setUrl:headerUrl];
    
}

-(void)setType:(NSBubbleType)value{
    type=value;
    UIImage* img=nil;
    UIImage* imgHL=nil;
    NSMutableArray* array=[[NSMutableArray alloc] initWithCapacity:3];
    if(type==BubbleTypeSomeoneElse){
        img=receiveImg;
        imgHL=receiveHLImg;
        for(int i=1;i<4;i++){
            UIImage* img=[UIImage imageNamed:[NSString stringWithFormat:@"bottleReceiverVoiceNodePlaying%03d.png",i]];
            [array addObject:img];
        }
    }
    else{
        img=senderImg;
        imgHL=senderHLImg;
        for(int i=1;i<4;i++){
            UIImage* img=[UIImage imageNamed:[NSString stringWithFormat:@"SenderVoiceNodePlaying%03d.png",i]];
            [array addObject:img];
        }
    }
    [button setBackgroundImage:img forState:UIControlStateNormal];
    [button setBackgroundImage:imgHL forState:UIControlStateHighlighted];

    voiceImageView.image=[array objectAtIndex:2];
    voiceImageView.animationImages=array;
    
    CGRect rect=voiceImageView.frame;
    rect.size=((UIImage*)[array objectAtIndex:0]).size;
    voiceImageView.frame=rect;
}

-(void)voiceLength:(float)voiceLegth animate:(BOOL)animate{
    voiceWidth=[UIImage imageNamed:@"VOIPReceiverVoiceNodeBkg.png"].size.width;
    
    voiceWidth=voiceWidth+(voiceWidth/5.0f * voiceLegth);
    if(voiceWidth>MAX_WIDTH)
        voiceWidth=MAX_WIDTH;
    if(animate){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
    }
    
    CGRect rect=button.frame;
    rect.size.width=voiceWidth;
    button.frame=rect;

    
    if(animate){
        [UIView commitAnimations];
    }
}

-(void)playAnimated:(BOOL)play{
    if(play){
        [voiceImageView startAnimating];
    }
    else{
        [voiceImageView stopAnimating];
    }
}

-(void)name:(NSString*)name{
    nameLabel.text=name;
}
-(void)sendDate:(NSDate*)date{
    NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"发送时间：yyyy-MM-dd HH:mm:ss"];
    dateLabel.text=[formatter stringFromDate:date];

}

-(void)setStatus:(int)value{
    if(status==value)return;
    status=value;
    if(status==0){
        [statusView removeFromSuperview];
        statusView=nil;
        UIActivityIndicatorView* __statusView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        __statusView.color=[UIColor blackColor];
        __statusView.frame=CGRectMake(0.0f, 0.0f, 16.0f, 16.0f);
        [self addSubview:__statusView];
        [__statusView startAnimating];
        statusView=__statusView;
    }
    else if(status==1){
        [statusView removeFromSuperview];
        statusView=nil;
        UIImageView* __statusView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"privacy_tick.png"]];
        [self addSubview:__statusView];
        statusView=__statusView;
    }
    else if(status==-1){
        [statusView removeFromSuperview];
        statusView=nil;
        UIImageView* __statusView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
        [self addSubview:__statusView];
        statusView=__statusView;

    }
    else{
        [statusView removeFromSuperview];
        statusView=nil;

    }
}


+(float)cellHeight:(NSBubbleType)type{
    return 90.0f;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    float cellHeight=[VoiceCell cellHeight:type];
    if (type == BubbleTypeSomeoneElse){
        
        CGRect rect=nameLabel.frame;
        rect.origin.x=10.0f;
        rect.origin.y=cellHeight-rect.size.height-5.0f;
        nameLabel.frame=rect;
        
        rect=imageView.frame;
        rect.origin.x=10.0f;
        rect.origin.y=CGRectGetMinY(nameLabel.frame)-rect.size.height;
        imageView.frame=rect;
        
        
        rect=dateLabel.frame;
        rect.origin.x=CGRectGetMaxX(imageView.frame)+5.0f;
        rect.origin.y=cellHeight-rect.size.height-5.0f;
        dateLabel.frame=rect;
        dateLabel.textAlignment=NSTextAlignmentLeft;

        
        rect=button.frame;
        rect.origin.x=CGRectGetMaxX(imageView.frame);
        rect.origin.y=CGRectGetMinY(dateLabel.frame)-rect.size.height;
        button.frame=rect;
        
        rect=voiceImageView.frame;
        rect.origin.x=25.0f;
        rect.origin.y=(button.frame.size.height-rect.size.height)*0.5f;
        voiceImageView.frame=rect;
        
        
        rect=statusView.frame;
        rect.origin.x=CGRectGetMaxX(button.frame)+5.0f;
        rect.origin.y=CGRectGetMinY(button.frame)+(button.frame.size.height-rect.size.height)*0.5f;
        statusView.frame=rect;
        
    }
    else {
        CGRect rect=nameLabel.frame;
        rect.origin.x=self.frame.size.width-10.0-rect.size.width;
        rect.origin.y=cellHeight-rect.size.height-5.0f;
        nameLabel.frame=rect;
        
        rect=imageView.frame;
        rect.origin.x=self.frame.size.width-10.0-rect.size.width;
        rect.origin.y=CGRectGetMinY(nameLabel.frame)-rect.size.height;
        imageView.frame=rect;
        
        rect=dateLabel.frame;
        rect.origin.x=CGRectGetMinX(imageView.frame)-rect.size.width-5.0f;
        rect.origin.y=cellHeight-rect.size.height-5.0f;
        dateLabel.frame=rect;
        dateLabel.textAlignment=NSTextAlignmentRight;

        
        rect=button.frame;
        rect.origin.x=CGRectGetMinX(imageView.frame)-rect.size.width;
        rect.origin.y=CGRectGetMinY(dateLabel.frame)-rect.size.height;
        button.frame=rect;

        rect=voiceImageView.frame;
        rect.origin.x=button.frame.size.width-rect.size.width-25.0f;
        rect.origin.y=(button.frame.size.height-rect.size.height)*0.5f;
        voiceImageView.frame=rect;

        
        rect=statusView.frame;
        rect.origin.x=CGRectGetMinX(button.frame)-rect.size.width-5.0f;
        rect.origin.y=CGRectGetMinY(button.frame)+(button.frame.size.height-rect.size.height)*0.5f;
        statusView.frame=rect;
    }
}


-(void)addVoiceButton:(id)target action:(SEL)action{
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark  asyncimage delegate


@end

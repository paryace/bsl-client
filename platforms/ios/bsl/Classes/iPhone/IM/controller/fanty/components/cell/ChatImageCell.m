//
//  ChatImageCell.m
//  cube-ios
//
//  Created by apple2310 on 13-9-9.
//
//

#import "ChatImageCell.h"
#import "ImageDownloadedView.h"
#import "ServerAPI.h"
#define CELL_SIZE 100.0f

@interface ChatImageCell()
-(void)avatorClick;
@end


@implementation ChatImageCell
@synthesize delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType=UITableViewCellAccessoryNone;
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        
        CGRect rect=CGRectMake(0.0f, 0.0f, 55.0f, 55.0f);
        
        imageView=[[ImageDownloadedView alloc] initWithFrame:rect];
        imageView.loadingImageName=@"NoHeaderImge.png";
        //        imageView.radius=4.0f;
        [self addSubview:imageView];
        
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 15.0f)];
        nameLabel.font=[UIFont systemFontOfSize:11.0f];
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.textAlignment=NSTextAlignmentCenter;
        nameLabel.backgroundColor=[UIColor clearColor];
        [self addSubview:nameLabel];

        
        
        bubbleView=[[UIImageView alloc] init];
        [self addSubview:bubbleView];
        
        UIImage* img=[UIImage imageNamed:@"shake_-transportphoto_Avatar.png"];
        
        avatorView=[UIButton buttonWithType:UIButtonTypeCustom];
        [avatorView addTarget:self action:@selector(avatorClick) forControlEvents:UIControlEventTouchUpInside];
        [avatorView setBackgroundImage:img forState:UIControlStateNormal];
        avatorView.frame=CGRectMake(0.0f, 0.0f, CELL_SIZE, CELL_SIZE);
        
        [self addSubview:avatorView];

        
        contentImageView=[[ImageDownloadedView alloc] initWithFrame:avatorView.bounds];
        contentImageView.loadingImageName=@"shake_-transportphoto_without_icon.png";
        contentImageView.showLoading=YES;
        [avatorView addSubview:contentImageView];
        
        
        
        dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 20.0f)];
        dateLabel.font=[UIFont systemFontOfSize:12.0f];
        dateLabel.textColor=[UIColor blackColor];
        dateLabel.backgroundColor=[UIColor clearColor];
        dateLabel.adjustsFontSizeToFitWidth=YES;
        [self addSubview:dateLabel];

    }
    return self;
}

+(float)cellHeight:(NSBubbleType)bubbleType{
    return CELL_SIZE+70.0f;
}

-(void)headerUrl:(NSString*)headerUrl name:(NSString*)name imageFile:(NSString*)imageFile sendDate:(NSDate*)date bubbleType:(NSBubbleType)bubbleType{
    
    [imageView setUrl:headerUrl];
    //imageFile=@"T1saYTByxT1RCvBVdK";
    
    if([[NSFileManager defaultManager] fileExistsAtPath:imageFile]){
        [contentImageView setUrl:imageFile];
    }
    else{
        NSString *url = [ServerAPI urlForAttachmentId:imageFile];
        url=[url stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],kAPPKey];
        [contentImageView setUrl:url];
    }
    
    nameLabel.text=name;
    NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"发送时间：yyyy-MM-dd HH:mm:ss"];
    dateLabel.text=[formatter stringFromDate:date];


    float cellHeight=CELL_SIZE+70.0f;
    
    if (bubbleType == BubbleTypeSomeoneElse){
        
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
        rect.origin.y=cellHeight-rect.size.height+5.0f;
        dateLabel.frame=rect;
        dateLabel.textAlignment=NSTextAlignmentLeft;

        
        bubbleView.image=[ChatCell bubbleSomeoneImg];
        bubbleView.frame=CGRectMake(CGRectGetMaxX(imageView.frame), CGRectGetMinY(dateLabel.frame)-CELL_SIZE-25.0f+5.0f, CELL_SIZE+30.0f, CELL_SIZE+25.0f);
        rect=avatorView.frame;
        rect.origin.x=CGRectGetMaxX(imageView.frame)+15.0f;
        rect.origin.y=(bubbleView.frame.size.height-rect.size.height)*0.5f-3.0f+35.0f;
        avatorView.frame=rect;
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

        bubbleView.image=[ChatCell bubbleMineImg];
        bubbleView.frame=CGRectMake(CGRectGetMinX(imageView.frame)-CELL_SIZE-30.0f, CGRectGetMinY(dateLabel.frame)-CELL_SIZE-25.0f+5.0f, CELL_SIZE+30.0f, CELL_SIZE+25.0f);
        rect=avatorView.frame;
        rect.origin.x=CGRectGetMinX(imageView.frame)-15.0f-rect.size.width-5.0f;
        rect.origin.y=(bubbleView.frame.size.height-rect.size.height)*0.5f-3.0f+25.0f;
        avatorView.frame=rect;
    }
    
}

-(void)avatorClick{
    if(contentImageView.image!=nil){
        if([self.delegate respondsToSelector:@selector(chatImageCellDidSelect:url:)])
            [self.delegate chatImageCellDidSelect:self url:contentImageView.url];
    }
}

@end

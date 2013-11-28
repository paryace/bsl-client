//
//  ChatCell.m
//  WeChat
//
//  Created by apple2310 on 13-9-5.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import "ChatCell.h"
#import "AsyncImageView.h"

#define MAX_WIDTH 180.0f


#define BEGIN_FLAG @"[/:"
#define END_FLAG @"]"

#define KFacialSizeWidth  20
#define KFacialSizeHeight 20

static UIImage*  __bubbleSomeoneImg=nil;
static UIImage* __bubbleMineImg=nil;

@interface ChatCell()<AsyncImageViewDelegate>

+(void)getImageRange:(NSString*)message : (NSMutableArray*)array;
+(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself dictionary:(NSDictionary*)dictionary;

@end

@implementation ChatCell

@synthesize emoctionList;

+(UIImage*)bubbleSomeoneImg{
    if(__bubbleSomeoneImg==nil){
        __bubbleSomeoneImg=[[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    }
    return __bubbleSomeoneImg;
}

+(UIImage*)bubbleMineImg{
    if(__bubbleMineImg==nil){
        __bubbleMineImg=[[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }
    return __bubbleMineImg;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType=UITableViewCellAccessoryNone;
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        noHeaderView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoHeaderImge.png"]];
        CGRect rect=noHeaderView.frame;
        rect.size=CGSizeMake(55.0f, 55.0f);
        noHeaderView.frame=rect;
        imageView=[[AsyncImageView alloc] initWithFrame:noHeaderView.frame];
        imageView.delegate=self;
        [self addSubview:imageView];
        [self addSubview:noHeaderView];
        nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 15.0f)];
        nameLabel.font=[UIFont systemFontOfSize:11.0f];
        nameLabel.textAlignment=NSTextAlignmentCenter;
        nameLabel.textColor=[UIColor blackColor];
        nameLabel.backgroundColor=[UIColor clearColor];
        [self addSubview:nameLabel];
        bubbleView=[[UIImageView alloc] init];
        [self addSubview:bubbleView];
        
        dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 20.0f)];
        dateLabel.font=[UIFont systemFontOfSize:12.0f];
        dateLabel.textColor=[UIColor blackColor];
        dateLabel.backgroundColor=[UIColor clearColor];
        dateLabel.adjustsFontSizeToFitWidth=YES;
        [self addSubview:dateLabel];
        
        contentLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        contentLabel.numberOfLines=0;
        contentLabel.backgroundColor=[UIColor clearColor];
        contentLabel.font=[UIFont fontWithName:@"Helvetica" size:13.0f];
        contentLabel.textColor=[UIColor blackColor];
        [self addSubview:contentLabel];
        
        
    }
    return self;
}

-(void)dealloc{
    imageView.delegate=nil;
}

+(float)cellHeight:(NSString*)content bubbleType:(NSBubbleType)bubbleType emoctionList:(NSDictionary*) emoctionList{
    float height=0.0f;
    /*
    UILabel* contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f,0.0f,MAX_WIDTH, 0.0f)];
    contentLabel.numberOfLines=0;
    contentLabel.font=[UIFont fontWithName:@"Helvetica" size:13.0f];
    contentLabel.textColor=[UIColor blackColor];
    contentLabel.text=content;
    [contentLabel sizeToFit];
    height=contentLabel.frame.size.height;
    [contentLabel release];
    */
    
    UIView* view=[ChatCell  assembleMessageAtIndex:content from:(bubbleType==BubbleTypeMine) dictionary:emoctionList];
    height=view.frame.size.height;
    return height+70.0f;
}

-(void)headerUrl:(NSString*)headerUrl name:(NSString*)name content:(NSString*)content sendDate:(NSDate*)date bubbleType:(NSBubbleType)bubbleType{
    noHeaderView.hidden=NO;
    if([headerUrl length]>0)
        [imageView loadImageWithURLString:headerUrl];
    nameLabel.text=name;
    NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"发送时间：yyyy-MM-dd HH:mm:ss"];
    dateLabel.text=[formatter stringFromDate:date];
    
    /*
    [contentLabel.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    contentLabel.text=content;
    contentLabel.frame = CGRectMake(0.0f,0.0f,MAX_WIDTH, 0.0f);
    [contentLabel sizeToFit];
    */
    [contentLabel.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIView* view=[ChatCell  assembleMessageAtIndex:content from:(bubbleType==BubbleTypeMine) dictionary:self.emoctionList];
    
    [contentLabel addSubview:view];
    contentLabel.frame=view.frame;

    float width=contentLabel.frame.size.width;
    float height=contentLabel.frame.size.height;
    float cellHeight=height+70.0f;

    if (bubbleType == BubbleTypeSomeoneElse){
        
        CGRect rect=nameLabel.frame;
        rect.origin.x=10.0f;
        rect.origin.y=cellHeight-rect.size.height+5.0f;
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
        bubbleView.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+5.0f, CGRectGetMinY(dateLabel.frame)-height-25.0f+5.0f, width+30.0f, height+25.0f);
        rect=contentLabel.frame;
        rect.origin.x=CGRectGetMaxX(imageView.frame)+18.0f;
        rect.origin.y=(bubbleView.frame.size.height-rect.size.height)*0.5f-3.0f+35.0f;
        contentLabel.frame=rect;
    }
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        nameLabel.text=[defaults valueForKey:@"zhName"];
        CGRect rect=nameLabel.frame;
        rect.origin.x=self.frame.size.width-10.0-rect.size.width;
        rect.origin.y=cellHeight-rect.size.height+5.0f;
        nameLabel.frame=rect;

        rect=imageView.frame;
        rect.origin.x=self.frame.size.width-10.0-rect.size.width;
        rect.origin.y=CGRectGetMinY(nameLabel.frame)-rect.size.height;
        imageView.frame=rect;
        
        rect=dateLabel.frame;
        rect.origin.x=CGRectGetMinX(imageView.frame)-rect.size.width-5.0f;
        rect.origin.y=cellHeight-rect.size.height+5.0f;
        dateLabel.frame=rect;
        dateLabel.textAlignment=NSTextAlignmentRight;

        
        bubbleView.image=[ChatCell bubbleMineImg];
        bubbleView.frame=CGRectMake(CGRectGetMinX(imageView.frame)-width-30.0f, CGRectGetMinY(dateLabel.frame)-height-25.0f+5.0f, width+30.0f, height+25.0f);
        rect=contentLabel.frame;
        rect.origin.x=CGRectGetMinX(imageView.frame)-18.0f-rect.size.width-5.0f;
        rect.origin.y=(bubbleView.frame.size.height-rect.size.height)*0.5f-3.0f+35.0f;
        contentLabel.frame=rect;
    }

    noHeaderView.frame=imageView.frame;
}


+(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}

+(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself dictionary:(NSDictionary*)dictionary{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont* fon=[UIFont fontWithName:@"Helvetica" size:13.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat Y = 0;
    CGFloat maxWidth=0.0f;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *str=[data objectAtIndex:i];

            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG]){
                if (upX >= MAX_WIDTH-10.0f){
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    Y = upY;
                }

                str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *imageName=[str substringWithRange:NSMakeRange(3, str.length - 4)];
                int index = [[dictionary allValues] indexOfObject:imageName];
                if([[dictionary allValues] indexOfObject:imageName] ==NSNotFound){
                    for (int j = 0; j < [imageName length]; j++) {
                        NSString *temp = [imageName substringWithRange:NSMakeRange(j, 1)];
                        if (upX >= MAX_WIDTH-10.0f){
                            upY = upY + KFacialSizeHeight;
                            upX = 0;
                            Y =upY;
                        }
                        if(upX>0 || ![temp isEqualToString:@" "]){
                            CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(200,CGFLOAT_MAX)];
                            UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                            la.font = fon;
                            la.text = temp;
                            la.lineBreakMode = UILineBreakModeWordWrap;
                            la.numberOfLines=0;
                            la.backgroundColor = [UIColor clearColor];
                            [returnView addSubview:la];
                            upX=upX+size.width;
                            maxWidth+=size.width;
                        }
                    }
                }
                else{
                    NSString * fileName = [[dictionary allKeys] objectAtIndex:index];
                    
                    UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",fileName]]];
                    img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                    [returnView addSubview:img];
                    upX=KFacialSizeWidth+upX;
                    maxWidth+=KFacialSizeWidth;
                }
                
                
                
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH-10.0f){
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        Y =upY;
                    }
                    if(upX>0 || ![temp isEqualToString:@" "]){
                        CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(200,CGFLOAT_MAX)];
                        UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                        la.font = fon;
                        la.text = temp;
                        la.lineBreakMode = UILineBreakModeWordWrap;
                        la.numberOfLines=0;
                        la.backgroundColor = [UIColor clearColor];
                        [returnView addSubview:la];
                        upX=upX+size.width;
                        maxWidth+=size.width;
                    }
                    
                }
            }
        }
    }
    if([array count]>0){
        Y+=KFacialSizeHeight;
    }
    if(maxWidth>=MAX_WIDTH)
        maxWidth=MAX_WIDTH;
    returnView.frame = CGRectMake(0.0f,0.0f, maxWidth, Y); //@ 需要将该view的尺寸记下，方便以后使用
    return returnView;
}




#pragma mark  async delegate

- (void)asyncImageView:(AsyncImageView *)asyncImageView didLoadImageFormURL:(NSURL*)aURL{
    noHeaderView.hidden=YES;
}


@end

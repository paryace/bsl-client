//
//  SecuritySettingsViewController.m
//  bsl
//
//  Created by zhoujun on 14-1-13.
//
//

#import "SecuritySettingsViewController.h"

@interface SecuritySettingsViewController ()

@end

@implementation SecuritySettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"安全设置";
    self.view.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"homebackImg.png"]];
    CGRect frame  = CGRectMake(10, 60, 100, 44);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"附件保留时间:";
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:titleLabel];
    
    UITextView *input = [[UITextView alloc]initWithFrame:frame];
    frame.origin.x = CGRectGetWidth(frame) + 5;
    frame.origin.y = CGRectGetMinY(frame)+7;
    frame.size.width = 36;
    frame.size.height = 36;
    input.frame = frame;
    input.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    input.textAlignment=NSTextAlignmentCenter;
    input.backgroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"text_bg.png"]];
    input.text = @"3";
    input.returnKeyType=UIReturnKeyDone;
    input.delegate = self;
    
    UILabel *dayLabel = [[UILabel alloc]initWithFrame:frame];
    dayLabel.text = @"天";
    dayLabel.font = [UIFont systemFontOfSize:14.0];
    dayLabel.backgroundColor = [UIColor clearColor];
    frame.origin.x = CGRectGetMinX(frame)+CGRectGetWidth(frame)+5;
    frame.origin.y = 60;
    frame.size.width= 13.0;
    frame.size.height= 44.0;
    dayLabel.frame = frame;
    [self.view addSubview:dayLabel];
    
    [self.view addSubview:input];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        BOOL isInt = [self isPureInt:textView.text];
        if(isInt)
        {
            if ([textView.text rangeOfString:@"0"].location ==0) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误提示" message:@"请输入0～31之间的整数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                return NO;
            }
            else
            {
                if([textView.text integerValue] >31 || [textView.text intValue]<=0)
                {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误提示" message:@"请输入0～31之间的整数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    return NO;
                }
                [[NSUserDefaults standardUserDefaults] setValue:textView.text forKey:@"day_time"];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误提示" message:@"请输入0～31之间的整数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return NO;
        }
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
- (BOOL)isPureInt:(NSString *)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

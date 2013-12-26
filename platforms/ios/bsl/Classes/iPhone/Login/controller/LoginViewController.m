//
//  ViewController.m
//  Mobile_Application_Platform
//
//  Created by Mr.幸 on 12-12-6.
//  Copyright (c) 2012年 Mr.幸. All rights reserved.
//

#import "LoginViewController.h"
#import "HTTPRequest.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import "ConfigManager.h"
#import "SVProgressHUD.h"
#import "UIColor+expanded.h"
#import "ServerAPI.h"
#import "Reachability.h"

@interface LoginViewController (){
    NSString* _deviceId;
}

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    
    
    
    
    [super viewDidLoad];
    
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@", shortVersion];
    
    _deviceId= [[UIDevice currentDevice] uniqueDeviceIdentifier];
    _username.delegate = self;
    _password.delegate = self;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _username.text = [defaults objectForKey:@"username"];
    _save.on = [defaults boolForKey:@"switchIsOn"];
    //------------------------------------------------------------------------------------------>
    //设置背景颜色
    [_loginBackgroundView setBackgroundColor:[UIColor colorWithRGBHex:0xe5e4e4]];
    
    //添加radioImageView事件,imageView的这个值默认是关闭的
    _radioImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage)];
    [_radioImage addGestureRecognizer:singleTap];
    
    NSString *status = [defaults objectForKey:@"status"];
    if ([status isEqualToString:@"on"]) {
        _radioImage.image = [UIImage imageNamed:@"Login_on.png"];
        _username.text = [defaults objectForKey:@"username"];
        _password.text = [defaults objectForKey:@"password"];
    }else{
        _radioImage.image = [UIImage imageNamed:@"Login_off.png"];
    }
    
    //------------------------------------------------------------------------------------------
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
            [_LoginView setFrame:CGRectMake(168, 222, 433, 334)];
            _backgroundImageView.image = [UIImage imageNamed:@"Login_Background_Portrait.png"];
        }else{
            [_LoginView setFrame:CGRectMake(296, 207, 433, 334)];
            _backgroundImageView.image = [UIImage imageNamed:@"Login_Background_Landscape.jpg"];
        }
    }
	// Do any additional setup after loading the view, typically from a nib.
}

//------------------------------------------------------------------------------------------>
-(void)onClickImage{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *status = [defaults objectForKey:@"status"];
    if ([status isEqualToString:@"on"]) {
        _radioImage.image = [UIImage imageNamed:@"Login_off.png"];
        [defaults setValue:@"off" forKey:@"status"];
        [defaults setObject:@"" forKey:@"username"];
        [defaults setObject:@"" forKey:@"password"];
    }else{
        if (![_username.text isEqualToString:@""]) {
            [defaults setObject:_username.text forKey:@"username"];
            [defaults setObject:_password.text forKey:@"password"];
        }
        _radioImage.image = [UIImage imageNamed:@"Login_on.png"];
        [defaults setValue:@"on" forKey:@"status"];
    }
}
//------------------------------------------------------------------------------------------

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
    }else{
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        {
            [_LoginView setFrame:CGRectMake(168, 222, 433, 334)];
            _backgroundImageView.image = [UIImage imageNamed:@"Login_Background_Portrait.png"];
        }
        else
        {
            [_LoginView setFrame:CGRectMake(296, 207, 433, 334)];
            _backgroundImageView.image = [UIImage imageNamed:@"Login_Background_Landscape.jpg"];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _offLineSwitch.hidden = YES;
    if (_offLineSwitch) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [_offLineSwitch setOn:(BOOL)[defaults objectForKey:@"offLineSwitch"]];
    }
}

- (IBAction)login:(id)sender {
    if ([_username.text isEqualToString:@""] || [_password.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户名或密码不能为空！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        
    }else{
        if (_offLineSwitch && [_offLineSwitch isOn]) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            if ([[defaults objectForKey:@"loginUsername"] isEqualToString:[_username text]]&&[[defaults objectForKey:@"loginPassword"] isEqualToString:[_password text]]) {
                [defaults setBool:YES forKey:@"offLineSwitch"];
                [defaults setObject:@"" forKey:@"token"];
                [defaults synchronize];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate didLogin];
            }
            return;
        }
        [_username resignFirstResponder];
        [_password resignFirstResponder];
        [SVProgressHUD showWithStatus:@"正在登录..." maskType:SVProgressHUDMaskTypeGradient ];
        NSLog(@"%@",[ServerAPI urlForLogin]);
        FormDataRequest* request = [FormDataRequest requestWithURL:[NSURL URLWithString:[ServerAPI urlForLogin]]];
        
        NSString * appId = [[NSBundle mainBundle]bundleIdentifier];
        //         [request setPostValue:@"json" forKey:@"resultType"];
        [request setPostValue:_username.text forKey:@"username"];
        [request setPostValue:_password.text forKey:@"password"];
        [request setPostValue:_deviceId forKey:@"deviceId"];
        [request setPostValue:appId forKey:@"appId"];
        [request setPostValue:kAPPKey forKey:@"appKey"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(getResult:)];
        [request setDidFailSelector:@selector(getFailMessage:)];
        [request startAsynchronous];
    }
    
}

- (IBAction)savePassword:(id)sender {
    UISwitch* save = sender;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([save isOn]) {
        if (![_username.text isEqualToString:@""]) {
            [defaults setObject:_username.text forKey:@"username"];
            [defaults setBool:YES forKey:@"switchIsOn"];
        }
        
    }else{
        [defaults setObject:@"" forKey:@"username"];
        [defaults setBool:NO forKey:@"switchIsOn"];
    }
}

-(void)getFailMessage:(HTTPRequest *)request{
    [SVProgressHUD dismiss];
    NSData* data = [request responseData];
    NSString* dataToString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"message:%@",dataToString);
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"连接失败" message:@"网络问题或者服务器连接失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)getResult:(HTTPRequest *)request{
    
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    NSData* data = [request responseData];
    NSDictionary* messageDictionary = [data objectFromJSONData];
    NSString* messageAlert =   [messageDictionary objectForKey:@"message"];
    NSNumber* number =  [messageDictionary objectForKey:@"result"];
    if ([number boolValue]) {
        NSString* token = [messageDictionary objectForKey:@"sessionKey"];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if (![_save isOn]) {
            [defaults setBool:YES forKey:@"switchIsOn"];
            [defaults setObject:_username.text forKey:@"username"];
            [defaults setObject:_password.text forKey:@"password"];
        }else{
            [defaults setObject:@"" forKey:@"username"];
            [defaults setObject:@"" forKey:@"password"];
            [defaults setBool:NO forKey:@"switchIsOn"];
        }
        //------------------------------------------------------------------------------------------
        
        [defaults setObject:_username.text forKey:@"loginUsername"];
        [defaults setObject:_password.text forKey:@"loginPassword"];
        
        [defaults setObject:token forKey:@"token"];
        [defaults setObject:_username.text forKey:@"LoginUser"];
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        [cubeApp sync];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate didLogin];
        
    }else{
        if ([messageAlert length] <= 0) {
            messageAlert = @"服务器出错，请联系管理员！";
        }
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"网络异常" message:messageAlert delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
        
    
    
    
}

/**
 开始编辑UITextField的方法
 */
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFrame =  textField.frame;
    float textY = textFrame.origin.y+textFrame.size.height;
    float bottomY = self.view.frame.size.height-textY;
    
    int textHight = 216;
    float moveY = 155;
    if (iPhone5) {
        textHight = 300;
        moveY= 130;
    }
    if(bottomY>=textHight)  //判断当前的高度是否已经有216，如果超过了就不需要再移动主界面的View高度
    {
        prewTag = -1;
        return;
    }
    prewTag = textField.tag;
    
    
    prewMoveY = moveY;
    
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y -=moveY;//view的Y轴上移
    frame.size.height +=moveY; //View的高度增加
    self.view.frame = frame;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
}

/**
 结束编辑UITextField的方法，让原来的界面还原高度
 */
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if(prewTag == -1) //当编辑的View不是需要移动的View
    {
        return;
    }
    float moveY ;
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    if(prewTag == textField.tag) //当结束编辑的View的TAG是上次的就移动
    {   //还原界面
        moveY =  prewMoveY;
        frame.origin.y =0;
        frame.size. height -=moveY;
        self.view.frame = frame;
    }
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

- (void)viewDidUnload {
    [self setLoginBackgroundView:nil];
    [self setRadioImage:nil];
    [self setVersionLabel:nil];
    [self setOffLineSwitch:nil];
    [super viewDidUnload];
}
@end

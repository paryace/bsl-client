//
//  SetttingIMViewController.m
//  cube-ios
//
//  Created by 东 on 13-3-27.
//
//

#import "SetttingIMViewController.h"
#import "AppDelegate.h"
@interface SetttingIMViewController ()

@end

@implementation SetttingIMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"即时通讯设置";
    }
    return self;
}



- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(PUSHOffLine) name:@"XMPPSTREAMPUSHOFFLINE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(PUSHOnLine) name:@"XMPPSTREAMPUSHONLINE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(IMOffLine) name:@"XMPPSTREAMIMOFFLINE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(IMOnLine) name:@"XMPPSTREAMIMONLINE" object:nil];
    
    [super viewDidLoad];
    //即时通讯
    if ([[[ShareAppDelegate xmpp]xmppStream] isConnected] ) {
        self.IMStatue.text = @"已连接";
        [self.switchIM setOn:YES];
    }else{
        self.IMStatue.text = @"未连接";
        [self.switchIM setOn:NO];
    }
    
//    //推送服务
//    if ([[[ShareAppDelegate xmppPustActor]xmppStream] isConnected] ) {
//        self.PushStatue.text = @"已连接";
//        [self.switchPUSH setOn:YES];
//    }else{
//        self.PushStatue.text = @"未连接";
//        [self.switchPUSH setOn:NO];
//    }
    
    
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    if ((BOOL)[defaults objectForKey:@"offLineSwitch"]) {
//        self.switchPUSH.enabled = NO;
//        self.switchIM.enabled = NO;
//    }else{
//        self.switchPUSH.enabled = YES;
//        self.switchIM.enabled = YES;
//    }
}

-(void)IMOnLine{
    self.IMStatue.text = @"已连接";
    [self.switchIM setOn:YES];
}
-(void)IMOffLine{
    self.IMStatue.text = @"未连接";
    [self.switchIM setOn:NO];
}
-(void)PUSHOffLine{
//    self.PushStatue.text = @"未连接";
//    [self.switchPUSH setOn:NO];
}
-(void)PUSHOnLine{
//    self.PushStatue.text = @"已连接";
//    [self.switchPUSH setOn:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setIMStatue:nil];
//    [self setPushStatue:nil];
    [self setSwitchIM:nil];
//    [self setSwitchPUSH:nil];
    [super viewDidUnload];
}

- (IBAction)switchIMTouchdown:(id)sender {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"offLineSwitch"])
    {
        
        if ([[[ShareAppDelegate xmpp]xmppStream] isConnected] ) {
            [[ShareAppDelegate xmpp] disConnect];
            [defaults setBool:YES forKey:@"IMXMPP"];
        }else{
            [[ShareAppDelegate xmpp] setupXmppStream];
            [defaults setBool:NO forKey:@"IMXMPP"];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"离线模式不能打开即时通讯连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        alertView = nil;
        UISwitch *switchs = (UISwitch*)sender;
        [switchs setOn:NO animated:YES];
        
    }
    
}

- (IBAction)switchPushTouchdown:(id)sender {
}
@end

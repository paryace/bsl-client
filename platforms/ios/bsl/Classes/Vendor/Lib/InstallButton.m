//
//  UIInstallButton.m
//  Cube-iOS
//
//  Created by 甄健鹏(Alfredo) on 1/23/13.
//
//

#import "InstallButton.h"

@implementation InstallButton
@synthesize btnStatus = _btnStatus;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.btnStatus = InstallButtonStateUninstall;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.btnStatus = InstallButtonStateUninstall;
    }
    return self;
}

-(void)dealloc{
    [self removeSelfFromObserverObj];
}

-(void)setBtnStatus:(enum InstallButtonStatus)newBtnStatus{
    _btnStatus = newBtnStatus;
    [self reDrawButton:self.frame];
}

-(void)reDrawButton:(CGRect)frame{
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,self.frame.size.height);
    [self setTitleColor:[UIColor grayColor]  forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self setBackgroundImage:[UIImage imageNamed:@"installbtnbg@2x.png"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"installbtnbg_active@2x.png"] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"installbtnbg_active@2x.png"] forState:UIControlStateHighlighted];
    
    
    switch (self.btnStatus) {
        case InstallButtonStateInstalling:
            [self drawInstalling];
            break;
        case InstallButtonStateInstalled:
            [self drawInstalled];
            break;
        case InstallButtonStateUpdatable:
            [self drawUpdatatable];
            break;
        case InstallButtonStateUpdating:
            [self drawUpdating];
            break;
        case InstallButtonStateSyn:
            [self removeSelfFromObserverObj];
            [self drawUninstallSyn];
            break;
        case InstallButtonStateDeleting:
            [self drawDeleting];
            break;
        case InstallButtonStateSynFailed:
            break;
        default:
            [self drawUninstall];
            break;
    }
}

-(void)drawUninstallSyn{
    [self setTitle:@"同步中" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setEnabled:YES];
}

-(void)drawUninstall{
    [self setTitle:@"安装" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setEnabled:YES];
}


-(void)drawInstalled{
    [self setTitle:@"删除" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setEnabled:YES];
}

-(void)drawInstalling{
    [self setTitle:@"正在安装" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setEnabled:NO];
}

-(void)drawUpdatatable{
    [self setTitle:@"更新" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    [self setEnabled:YES];
}

-(void)drawUpdating{
    [self setTitle:@"正在更新" forState:UIControlStateDisabled];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setEnabled:NO];
}

-(void)drawDeleting{
    [self setTitle:@"正在删除" forState:UIControlStateDisabled];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setEnabled:NO];
}


-(void)observerOperation:(id)observedObj{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawInstalling) name:CubeModuleDownloadDidFinishNotification object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawInstalled) name:CubeModuleInstallDidFinishNotification object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawUninstall) name:CubeModuleInstallDidFailNotification object:observedObj];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawUninstall) name:CubeModuleDownloadDidFailNotification object:observedObj];
}

-(void)removeSelfFromObserverObj{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleDownloadDidFinishNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleInstallDidFinishNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleInstallDidFailNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CubeModuleDownloadDidFailNotification object:nil];
}

@end

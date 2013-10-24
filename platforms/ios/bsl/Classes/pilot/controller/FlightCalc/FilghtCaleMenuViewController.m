//
//  MenuViewController.m
//  FlightCalc
//
//  Created by apple on 11-6-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilghtCaleMenuViewController.h"
#import "LevelViewController.h"
#import "About.h"
#import "Calc60.h"
#import "CAS-TAS.h"
#import "CloudHeight.h"
#import "CloudBase.h"
#import "CDA1.h"
#import "SDA.h"
#import "Fuel.h"
#import "Qnhqfe.h"
#import "Turn.h"
#import "Unit.h"
#import "Wind.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>
#import <CommonCrypto/CommonDigest.h>


void byte2key(unsigned char* b,unsigned char*hs) ;


@interface FilghtCaleMenuViewController (){
    
    NSMutableArray *titleArray;
}

@end

@implementation FilghtCaleMenuViewController



@synthesize controllers;
@synthesize companyField,nameField,emailField,keyField,devIdLabel;
@synthesize mAlertViewSuper,mAlertView;

NSUInteger selectRow;

- (IBAction) GetKey:(id) sender {
	[self backgroundTap:sender];
	if ([companyField.text length]<1) {
		[keyField setPlaceholder:@"Company Error!"];
	} else if ([nameField.text length]<1) {
		[keyField setPlaceholder:@"Name Error!"];
	} else if ([emailField.text length]<1) {
		[keyField setPlaceholder:@"Email Error!"];
	} else if (![self connectedToNetwork]) { 	// is connect network
		[keyField setText:@""];
		[keyField setPlaceholder:@"No network!"];
	} else { // network ok
		//[keyField setText:@"ASLDJFLSADJF"];
		[keyField setText:@"Please Wait..."];

		myActivityAlert=[[UIAlertView alloc] initWithTitle:nil message:@"Getting key,Wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityView.frame=CGRectMake(120.f, 50.f, 32.f, 32.f);
		[myActivityAlert addSubview:activityView];
		[activityView startAnimating];
		[activityView release];
		[myActivityAlert show];
		
		[NSThread detachNewThreadSelector:@selector(postdata) toTarget:self withObject:nil];
		//[self postdata];
		
	}
	
}
- (void) GetKeyFinished:(NSData *)returnData {
	if(returnData)
	{
		NSString *result = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
		if ([result hasPrefix:@"Key="]) {
			[keyField setText:[result substringFromIndex:4]];	
		} else {
			[keyField setText:@"Server ERR!"];
		}
		[result release];
		//NSLog(@"result=======&gt;%@",result);
	}
	else
	{
		[keyField setText:@"Connection ERR!"];
		//NSLog(@"Wrong Connetion!");
	}
	[myActivityAlert dismissWithClickedButtonIndex:0 animated:YES];
	[myActivityAlert release];	
}

-(void)postdata{
	//NSLog(@"TEST");
	
	//[NSThread sleepForTimeInterval:3]; // for test,sleep 3 sec

	NSURL *url;
	NSMutableURLRequest *urlRequest;
	NSMutableData *postBody = [NSMutableData data];
	
	url = [NSURL URLWithString:@"http://fxb.csair.com/flightcalc/autoreg.php"];
	urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"POST"];
	
	//NSString *udid = @"phong=15871485145&amp;psw=23";
	NSString *udid = [NSString stringWithFormat:@"reginfo1=%@&reginfo=%@&company=%@&name=%@&email=%@&auth=flt:apk",
					  myDeviceId,
					  myDeviceIdkey,
					  companyField.text,
					  nameField.text,
					  emailField.text];
	[postBody appendData:[udid dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion:YES]];
	
	[urlRequest setHTTPBody:postBody];
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];

	[self performSelectorOnMainThread:@selector(GetKeyFinished:) withObject:returnData waitUntilDone:YES];
}

-(void) checkregsit{
	UIDevice *device=[UIDevice currentDevice];
	[myDeviceId setString:@""];
	[myDeviceId appendFormat:@"%@;%@;%@;%@;%@;%@;",
				[device name], //"My iPhone"
				[device model], // "iPhone" ,"iPod touch"
				[device localizedModel], // localized version of model
				[device systemName], //"iOS"
				[device systemVersion], //"4.0
				[device uniqueIdentifier] ]; //a string unique to each device based on various hardware info.
		//like this: 2b6f0cc904d137be2e1730235f5664094b831186. ;
	//UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:myDeviceId delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//[myAlert show];
	//[myAlert release];
	
	const char *s=[myDeviceId UTF8String];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH]={0};
	//NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
	//CC_SHA1(keyData.bytes, keyData.length, digest);
	CC_SHA1(s, strlen(s), digest);
	unsigned char key[20];
	byte2key(digest, key);
	int n=strlen((char*)key);
	key[n]='P';
	key[n+1]=FlightCalcSuffix;
	key[n+2]=0;
	[myDeviceIdkey setString:[NSString stringWithUTF8String:(char *)key]];
	/*
	NSData *tmp=[NSData dataWithBytes:key length:CC_SHA1_DIGEST_LENGTH];
	NSString *tmp1=[tmp description];
	UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:myDeviceIdkey message:tmp1 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[myAlert show];
	[myAlert release];
	*/
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory=[paths objectAtIndex:0];
	NSString *filename=[documentsDirectory stringByAppendingPathComponent:@"FlightCalc.db"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		NSArray *array=[[NSArray alloc] initWithContentsOfFile:filename];
		NSString *buf=[NSString stringWithFormat:@"%@%@%@%@20110711*Captain_lili,dI*5@dHI",
					   myDeviceIdkey,
					   [array objectAtIndex:0],
					   [array objectAtIndex:1],
					   [array objectAtIndex:2] ];
		s=[buf UTF8String];
		CC_SHA1(s, strlen(s), digest);
		byte2key(digest, key);
		if([[array objectAtIndex:3] caseInsensitiveCompare:[NSString stringWithUTF8String:(char *)key]]
		   ==NSOrderedSame){
			isRegisted=YES;
		} else {
			isRegisted=NO;
		}
		[array release];
	}
}

void byte2key(unsigned char *b,unsigned char*hs) {
	char stmp;
	char c;
	int n;
	for(n=0;n<CC_SHA1_DIGEST_LENGTH;n+=2){
		c=(char) (((b[n] & 0xFF)^(b[n+1] & 0xFF)) % 35);
		if(c<9) {
			stmp=(char)( c + '1' );
		} else {
			stmp=(char)( c + 'A' - 9 );
		}
		hs[n/2]=stmp;
	}
	hs[n/2]=0x0;
}

- (IBAction) backgroundTap:(id) sender {
	[companyField resignFirstResponder];
	[nameField resignFirstResponder];
	[emailField resignFirstResponder];
	[keyField resignFirstResponder];
	companyField.text=[companyField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	nameField.text=[nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	emailField.text=[emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
-(IBAction) textFieldDoneEditting:(id) sender{
	//resultField.text=[NSString stringWithFormat:@"%d,%d",altField, sender];
	if (sender==companyField) {
		[nameField becomeFirstResponder];
	} else if (sender==nameField){
		[emailField becomeFirstResponder];
	} else if (sender==emailField || sender==keyField){
		[emailField resignFirstResponder];
		[keyField resignFirstResponder];
		//[self GetKey: sender];
	}
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"飞行计算器的计算数值与实际情况可能会有出入，在实际操作中仅供参考！" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil] autorelease];
    [alert show];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	self.title = [NSString stringWithFormat:@"FlightCalc %@", version];
	NSMutableArray *array = [[NSMutableArray alloc] init];
    titleArray=[[NSMutableArray alloc] init];

	//about
	About *myView1=[[About alloc] initWithNibName:@"About" bundle:nil];
	myView1.title=@"About & Help";
    [titleArray addObject:@"About & Help"];
	[array addObject:myView1];
	[myView1 release];
	//calc60
	Calc60 *myView2=[[Calc60 alloc] initWithNibName:@"Calc60" bundle:nil];
	myView2.title=@"60 Calc";
    [titleArray addObject:@"60 Calc"];
	[array addObject:myView2];
	[myView2 release];
	//cas-tas
	CAS_TAS *myView3=[[CAS_TAS alloc] initWithNibName:@"CAS-TAS" bundle:nil];
	myView3.title=@"CAS-TAS";
    [titleArray addObject:@"CAS-TAS"];
	[array addObject:myView3];
	[myView3 release];
	//CloudHeight
	CloudHeight *myView4=[[CloudHeight alloc] initWithNibName:@"CloudHeight" bundle:nil];
	myView4.title=@"Cloud Height";
    [titleArray addObject:@"Cloud Height"];
	[array addObject:myView4];
	[myView4 release];
	//CloudBase
	CloudBase *myView5=[[CloudBase alloc] initWithNibName:@"CloudBase" bundle:nil];
	myView5.title=@"Cloud Base";
    [titleArray addObject:@"Cloud Base"];
	[array addObject:myView5];
	[myView5 release];
	//CDA
	CDA1 *myView6=[[CDA1 alloc] initWithNibName:@"CDA1" bundle:nil];
	myView6.title=@"Continuous Descent Approach";
    [titleArray addObject:@"Continuous Descent Approach"];
	[array addObject:myView6];
	[myView6 release];
	//SDA
	SDA *myView7=[[SDA alloc] initWithNibName:@"SDA" bundle:nil];
	myView7.title=@"Step Descent Approach";
    [titleArray addObject:@"Step Descent Approach"];
	[array addObject:myView7];
	[myView7 release];
	//Fuel
	Fuel *myView8=[[Fuel alloc] initWithNibName:@"Fuel" bundle:nil];
	myView8.title=@"Fuel";
    [titleArray addObject:@"Fuel"];
	[array addObject:myView8];
	[myView8 release];
	//QNH-QFE
	Qnhqfe *myView9=[[Qnhqfe alloc] initWithNibName:@"Qnhqfe" bundle:nil];
	myView9.title=@"QNH - QFE";
    [titleArray addObject:@"QNH - QFE"];
	[array addObject:myView9];
	[myView9 release];
	//Turn
	Turn *myView10=[[Turn alloc] initWithNibName:@"Turn" bundle:nil];
	myView10.title=@"Turn Radius";
    [titleArray addObject:@"Turn Radius"];
	[array addObject:myView10];
	[myView10 release];
	//UNIT conversion
	Unit *myView11=[[Unit alloc] initWithNibName:@"Unit" bundle:nil];
	myView11.title=@"Unit Conversion";
    [titleArray addObject:@"Unit Conversion"];
	[array addObject:myView11];
	[myView11 release];
	//Wind
	Wind *myView12=[[Wind alloc] initWithNibName:@"Wind" bundle:nil];
	myView12.title=@"Wind";
      [titleArray addObject:@"Wind"];
	[array addObject:myView12];
	[myView12 release];
	

//	//Exit
//	UIViewController *myView90=[[UIViewController alloc] initWithNibName:nil bundle:nil];
//	myView90.title=@"Exit";
//	[array addObject:myView90];
//	[myView90 release];
	
	//--------
	self.controllers=array;
	[array release];
	
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"alert-view-bg-portrait.png"] stretchableImageWithLeftCapWidth:142 topCapHeight:31]];
	[backgroundView setFrame:mAlertView.bounds];
	[mAlertView insertSubview:backgroundView atIndex:0];
	[backgroundView release];

	isRegisted=NO;
	myDeviceId=[[NSMutableString alloc] initWithCapacity:128];
	myDeviceIdkey=[[NSMutableString alloc] initWithCapacity:20];
	[self checkregsit];
	
	
}
-(void)viewDidUnload {
	self.controllers=nil;
	self.companyField=nil;
	self.nameField=nil;
	self.emailField=nil;
	self.keyField=nil;
	self.devIdLabel=nil;
	self.mAlertView=nil;
	self.mAlertViewSuper=nil;
	[super viewDidUnload];
}
-(void) dealloc{
	[controllers release];
	[companyField release];
	[nameField release];
	[emailField release];
	[keyField release];
	[devIdLabel release];
	[mAlertView release];
	[mAlertViewSuper release];
	[myDeviceId release];
	[myDeviceIdkey release];
    [titleArray release];
	[super dealloc];
}

/* no effect
-(void)willRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {	
	if (toInterfaceOrientation==UIInterfaceOrientationPortrait) {
		mAlertView.frame=CGRectMake(0, 20, 125, 125);
	} else {
		mAlertView.frame=CGRectMake(200, 20, 125, 125);
	}

}
*/

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section{
	return [self.controllers count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *MenuCell=@"MenuCell";
	UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:MenuCell];
	if (cell==nil){
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCell] autorelease];
	}
	//configure cell
	//NSUInteger row=[indexPath row];
	//LevelViewController *controller=[controllers objectAtIndex:row];
	cell.textLabel.text=[titleArray objectAtIndex:indexPath.row];
	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}
#pragma mark -
#pragma mark Table View Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath{
	NSUInteger row=[indexPath row];
	selectRow=row;
	LevelViewController *nextController=[self.controllers objectAtIndex:row];

	if ([nextController.title  isEqualToString: @"Exit"]) {
		[[UIApplication sharedApplication] performSelector:@selector(terminateWithSuccess)];
		//exit(EXIT_SUCCESS);
		return;
	}
	if (!isRegisted && ![nextController.title isEqualToString:@"About & Help"]) {
		[self showAlertView:tableView];
		[self goNext];
	} else{
       
    }

}

-(void) goNext{
	LevelViewController *nextController=[self.controllers objectAtIndex:selectRow];
	//UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
	//backItem.title=@"Back";
	//[self.navigationItem setBackBarButtonItem:backItem];
	//[backItem release];
	[self.navigationController pushViewController:nextController animated:YES];	
}

- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        //NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark animations

static CGFloat kTransitionDuration = 0.3f;

- (CGAffineTransform)transformForOrientation {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}
- (void)bounce2AnimationStopped{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	mAlertView.transform = [self transformForOrientation];
	[UIView commitAnimations];
}

- (void)bounce1AnimationStopped{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	mAlertView.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
	[UIView commitAnimations];
}
- (void)alertViewIsRemoved{
	[[mAlertViewSuper retain] removeFromSuperview];
	[mTempFullscreenWindow release];
	mTempFullscreenWindow = nil;
}

#pragma mark IBAction

- (IBAction)showAlertView:(id)sender {
//	if (!mTempFullscreenWindow) {
//		mTempFullscreenWindow=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//		mTempFullscreenWindow.windowLevel=UIWindowLevelStatusBar;
//		mTempFullscreenWindow.backgroundColor=[UIColor clearColor];
//		[mTempFullscreenWindow addSubview:mAlertViewSuper];
//		[mAlertViewSuper setAlpha:0.0f];
//		[mAlertViewSuper setFrame:[mTempFullscreenWindow bounds]];
//		[mTempFullscreenWindow makeKeyAndVisible];
//				
//		mAlertView.transform=CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
//		[UIView beginAnimations:nil context:nil];
//		[UIView setAnimationDuration:kTransitionDuration/1.5];
//		[UIView setAnimationDelegate:self];
//		[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
//		mAlertView.transform=CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
//		[mAlertViewSuper setAlpha:0.9f];
//		[UIView commitAnimations];
//	}

	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory=[paths objectAtIndex:0];
	NSString *filename=[documentsDirectory stringByAppendingPathComponent:@"FlightCalc.db"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		NSArray *array=[[NSArray alloc] initWithContentsOfFile:filename];
		companyField.text=[array objectAtIndex:0];
		nameField.text=[array objectAtIndex:1];
		emailField.text=[array objectAtIndex:2];
		[array release];
	} else {
		companyField.text=@"";
		nameField.text=@"";
		emailField.text=@"";
	}
	keyField.text=@"";
	devIdLabel.text=[NSString stringWithFormat:@"Reginfo:%@", myDeviceIdkey];
	
}
- (IBAction)dismissAlertView:(id)sender{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(alertViewIsRemoved)];
	[mAlertViewSuper setAlpha:0.0f];
	[UIView commitAnimations];
	
	[self backgroundTap:sender];
	NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory=[paths objectAtIndex:0];
	NSString *filename=[documentsDirectory stringByAppendingPathComponent:@"FlightCalc.db"];
	NSString *regKey;
	if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		NSArray *array=[[NSArray alloc] initWithContentsOfFile:filename];
		regKey=[NSString stringWithString:[array objectAtIndex:3]];
		[array release];
	} else regKey=@"";
	NSMutableArray *array=[[NSMutableArray alloc] init];
	[array addObject:companyField.text];
	[array addObject:nameField.text];
	[array addObject:emailField.text];
	if ([keyField.text length]>2) {
		[array addObject:keyField.text];
	} else 
		  [array addObject:regKey];
	[array addObject:myDeviceIdkey];
	[array writeToFile:filename atomically:YES];
	[array release];
	if ([keyField.text length]>2)
		[self checkregsit];
	
	[self goNext];
	
}

#pragma mark - Actions

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

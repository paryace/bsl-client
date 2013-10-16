//
//  ModularCDVViewController.h
//  MobileBrick
//
//  Created by Justin Yip on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
typedef void (^DidFinishPreloadBlock)(void);
typedef void (^DidErrorPreloadBlock)(void);

@interface CubeWebViewController : CDVViewController <UIAlertViewDelegate>

@property(nonatomic,assign)BOOL preventOnce;
@property(nonatomic,readonly) UIButton* closeButton;

@property(nonatomic,assign) BOOL alwaysShowNavigationBar;

- (void)loadWebPageWithModule:(CubeModule *)module
               didFinishBlock:(DidFinishPreloadBlock)didFinishBlock
                didErrorBlock:(DidErrorPreloadBlock)didErrorBolock;
- (void)loadWebPageWithModuleIdentifier:(NSString *)moduleIdentifier didFinishBlock:(DidFinishPreloadBlock)didFinishBlock didErrorBlock:(DidErrorPreloadBlock)didErrorBolock;
- (void)loadRequest:(NSURLRequest*)request withFrame:(CGRect)frame didFinishBlock:(DidFinishPreloadBlock)didFinishBlock;


- (void)loadRequest:(NSURLRequest*)request withFrame:(CGRect)frame didFinishBlock:(DidFinishPreloadBlock)didFinishBlock didErrorBlock:(DidErrorPreloadBlock)didErrorBolock;

- (void)loadSettingPageWithModule:(CubeModule *)module didFinishBlock:(DidFinishPreloadBlock)didFinishBlock didErrorBlock:(DidErrorPreloadBlock)didErrorBolock;

- (void)loadWebPageWithUrl:(NSString *)fileUrl didFinishBlock:(DidFinishPreloadBlock)didFinishBlock didErrorBlock:(DidErrorPreloadBlock)didErrorBolock;

- (void)loadWebPageWithModule:(CubeModule *)module frame:(CGRect)frame didFinishBlock:(DidFinishPreloadBlock)didFinishBlock  didErrorBlock:(DidErrorPreloadBlock)didErrorBolock;

@end

@interface CubeCommandDelegate : CDVCommandDelegateImpl
@property(nonatomic, weak)CDVViewController* viewController;
@end

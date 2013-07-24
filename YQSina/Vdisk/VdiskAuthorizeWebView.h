//
//  VdiskAuthorizeWebView.h
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class VdiskAuthorizeWebView;
@class VdiskAuthorize;

@protocol VdiskAuthorizeWebViewDelegate <NSObject>

- (void)authorizeWebView:(VdiskAuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code;

@end

@interface VdiskAuthorizeWebView : UIView <UIWebViewDelegate> {
    
    UIView *_panelView;
    UIView *_containerView;
    UIActivityIndicatorView *_indicatorView;
	UIWebView *_webView;
    UIInterfaceOrientation _previousOrientation;
    UIButton *_closeButton;
}

@property (nonatomic, assign) id<VdiskAuthorizeWebViewDelegate> delegate;
@property (nonatomic, assign) VdiskAuthorize *authorize;

- (void)loadRequestWithURL:(NSURL *)url;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;


@end

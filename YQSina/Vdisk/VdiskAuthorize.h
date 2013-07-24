//
//  VdiskAuthorize.h
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VdiskRequest.h"
#import "VdiskAuthorizeWebView.h"


@class VdiskAuthorize;

@protocol VdiskAuthorizeDelegate <NSObject>

@required

- (void)authorize:(VdiskAuthorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken userID:(NSString *)userID expiresIn:(NSInteger)seconds;
- (void)authorize:(VdiskAuthorize *)authorize didFailWithError:(NSError *)error;
- (void)authorizeDidCancel:(VdiskAuthorize *)authorize;

@end


@interface VdiskAuthorize : NSObject<
#if TARGET_OS_IPHONE
VdiskAuthorizeWebViewDelegate,
#endif
VdiskRequestDelegate> {
    
    NSString    *_appKey;
    NSString    *_appSecret;
    NSString    *_redirectURI;
    VdiskRequest   *_request;
    NSString *_udid;
}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, retain) VdiskRequest *request;
@property (nonatomic, assign) id<VdiskAuthorizeDelegate> delegate;

- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;
- (void)startAuthorize;
- (void)startAuthorizeUsingUsername:(NSString *)username password:(NSString *)password;
- (void)startAuthorizeUsingRefreshToken:(NSString *)refreshToken;



@end

//
//  VdiskAuthorize.m
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import "VdiskAuthorize.h"
#import "VdiskError.h"

@interface VdiskAuthorize ()
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;
- (void)requestAccessTokenWithUsername:(NSString *)username password:(NSString *)password;

@end

@implementation VdiskAuthorize

-(id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    
    if (self = [super init])
    {
        self.appKey = appKey;
        self.appSecret = appSecret;
    }
    return self;
}

-(void)startAuthorize
{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_appKey, @"client_id", @"code", @"response_type", _redirectURI, @"redirect_uri", @"mobile", @"display", @"true", @"forcelogin", nil];
    NSString *urlString = [VdiskRequest serializeURL:kVdiskAuthorizeURL params:params httpMethod:@"GET"];
    
    VdiskAuthorizeWebView *webView = [[VdiskAuthorizeWebView alloc]init];
    [webView setDelegate:self];
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
    
    [webView show:YES];
    webView.authorize = self;
    
}

//根据获取到的code去请求accesstoken
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_appKey, @"client_id", _appSecret, @"client_secret", @"authorization_code", @"grant_type", _redirectURI, @"redirect_uri", code, @"code", nil];
    
    [self.request disconnect];
    
    self.request = [VdiskRequest requestWithURL:kVdiskAccessTokenURL httpMethod:@"POST" params:params httpHeaderFields:nil delegate:self];

    [self.request connect];
}


- (void)requestAccessTokenWithUsername:(NSString *)username password:(NSString *)password {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_appKey, @"client_id", _appSecret, @"client_secret", @"password", @"grant_type", username, @"username", password, @"password", nil];
    
    [_request disconnect];
    
    self.request = [VdiskRequest requestWithURL:kVdiskAccessTokenURL httpMethod:@"POST" params:params httpHeaderFields:nil delegate:self];
    
    [_request connect];
}

-(void)startAuthorizeUsingUsername:(NSString *)username password:(NSString *)password
{
    [self requestAccessTokenWithUsername:username password:password];
}

-(void)startAuthorizeUsingRefreshToken:(NSString *)refreshToken
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_appKey, @"client_id", _appSecret, @"client_secret", @"refresh_token", @"grant_type", refreshToken, @"refresh_token", nil];
    
    NSLog(@"%@", params);
    
    [_request disconnect];
    
    self.request = [VdiskRequest requestWithURL:kVdiskAccessTokenURL httpMethod:@"POST" params:params httpHeaderFields:nil delegate:self];
    
    [_request connect];
}


#pragma mark - VdiskAuthorizeWebViewDelegate Methods

- (void)authorizeWebView:(VdiskAuthorizeWebView *)webView didReceiveAuthorizeCode:(NSString *)code {
    
    [webView hide:YES];
    
    // if not canceled
    if (![code isEqualToString:@"21330"]) {
        
        [self requestAccessTokenWithAuthorizeCode:code];
        
    } else {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizeDidCancel:)]) {
            
            [self.delegate authorizeDidCancel:self];
        }
    }
}

#pragma mark -VDiskRequestDelegate Method
-(void)request:(VdiskRequest *)request didFinishLoadingWithResult:(id)result
{
    
    NSLog(@"%@", result);
    
    BOOL success = NO;
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dict = (NSDictionary *)result;
        
        NSString *accessToken = [dict objectForKey:@"access_token"];
        NSString *refreshToken = [dict objectForKey:@"refresh_token"];
        NSString *userId = [dict objectForKey:@"uid"];
        //NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
        NSInteger seconds = [[dict objectForKey:@"time_left"] intValue] + [[NSDate date] timeIntervalSince1970];
        
        success = accessToken && refreshToken && seconds;
        
        if (success && [self.delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:refreshToken:userID:expiresIn:)]) {
            
            [self.delegate authorize:self didSucceedWithAccessToken:accessToken refreshToken:refreshToken userID:userId expiresIn:seconds];
        }
    }
    
    // should not be possible
    
    if (!success && [self.delegate respondsToSelector:@selector(authorize:didFailWithError:)]) {
        
        NSError *error = [NSError errorWithDomain:kVdiskErrorDomain code:kVdiskErrorInvalidResponse userInfo:nil];
        
        if ([self.delegate respondsToSelector:@selector(authorize:didFailWithError:)]) {
            
            [self.delegate authorize:self didFailWithError:error];
        }
    }
}


@end

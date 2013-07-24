//
//  YQVdiskSession.h
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VdiskAuthorize.h"


typedef enum {
    
    kVdiskSessionTypeDefault = 0,
	kVdiskSessionTypeWeiboAccessToken,
    
} VdiskSessionType;


@class YQVdiskSession;


@protocol VdiskSessionDelegate <NSObject>

@optional

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)sessionAlreadyLinked:(YQVdiskSession *)session;
// Log in successfully.
- (void)sessionLinkedSuccess:(YQVdiskSession *)session;
// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)session:(YQVdiskSession *)session didFailToLinkWithError:(NSError *)error;
// Log out successfully.
- (void)sessionUnlinkedSuccess:(YQVdiskSession *)session;
// When you use the VdiskSession's request methods,
// you may receive the following four callbacks.
- (void)sessionNotLink:(YQVdiskSession *)session;
- (void)sessionExpired:(YQVdiskSession *)session;
- (void)sessionLinkDidCancel:(YQVdiskSession *)session;

//- (void)sessionWeiboAccessTokenIsNull:(VdiskSession *)session;

@end


@interface YQVdiskSession : NSObject

@property (nonatomic, strong) NSString *appkey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *appRoot;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, strong) NSString *redirectURL;
@property (nonatomic) VdiskAuthorize *authorize;
@property (nonatomic) VdiskSessionType sessionType;
@property (nonatomic, weak) id<VdiskSessionDelegate> delegate;

@property (nonatomic, assign) BOOL isUserExclusive;

- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret appRoot:(NSString *)appRoot;
//
//- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret appRoot:(NSString *)appRoot sinaWeibo:(SinaWeibo *)sinaWeibo;
+ (YQVdiskSession   *)sharedSession;
+(void)setSharedSession:(YQVdiskSession *)session;
- (BOOL)isLinked;
-(BOOL)isExpired;
- (void)linkWithSessionType:(VdiskSessionType)sessionType;


@end

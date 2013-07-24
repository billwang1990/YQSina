//
//  YQVdiskSession.m
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import "YQVdiskSession.h"
#import "YQKeyChain.h"
//#import "YQRestClient.h"
#import "VDiskClient.h"

static YQVdiskSession *sharedSession = nil;

@interface YQVdiskSession()<VdiskSessionDelegate, VdiskAuthorizeDelegate, VDiskClientDelegate>

-(void)readAuthorizeDataFromKeychain;
- (NSString *)urlSchemeString;

@end

@implementation YQVdiskSession

+(YQVdiskSession *)sharedSession
{
    return sharedSession;
}

+(void)setSharedSession:(YQVdiskSession *)session
{
    if (session == sharedSession) {
        return;
    }
    sharedSession = session;
}

-(BOOL)isLinked
{
    return _userID && _accessToken && (_expireTime > 0);
}


-(id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret appRoot:(NSString *)appRoot
{
//    return [self initWithAppKey:appKey appSecret:appSecret appRoot:appRoot sinaWeibo:nil];
    if (self = [super init]) {
        self.appkey = appKey;
        self.appSecret = appSecret;

        if([appRoot isEqualToString:kVdiskRootAppFolder] || [appRoot isEqualToString:kVdiskRootBasic])
        {
            self.appRoot = appRoot;
        }
        else{
            self.appRoot = kVdiskRootAppFolder;
        }
        
        _sessionType = kVdiskSessionTypeDefault;
        _isUserExclusive = NO;
        [self readAuthorizeDataFromKeychain];
    }
    return self;
}

-(void)readAuthorizeDataFromKeychain
{
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kVdiskKeychainServiceNameSuffix];
    
    NSData *data = [YQKeyChain passwordDataForService:serviceName account:kVdiskKeychainAccountIdentity];
    
    
    if (data == nil || [data length] == 0) {
        return;
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    @try {
        self.userID = [unarchiver decodeObjectForKey:kVdiskKeychainUserID];
        self.accessToken = [unarchiver decodeObjectForKey:kVdiskKeychainAccessToken];
        self.refreshToken = [unarchiver decodeObjectForKey:kVdiskKeychainRefreshToken];
        self.expireTime = [unarchiver decodeDoubleForKey:kVdiskKeychainExpireTime];
        _sessionType = [unarchiver decodeIntForKey:kVdiskKeychainSessionType];
        
        
    }
    @catch (NSException *exception) {
        
        [self deleteAuthorizeDataInKeychain];
    }
    @finally {
        
    }
    
    [unarchiver finishDecoding];
    
}

- (void)saveAuthorizeDataToKeychain {
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kVdiskKeychainServiceNameSuffix];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
     [archiver encodeObject:_userID forKey:kVdiskKeychainUserID];
    [archiver encodeObject:_accessToken forKey:kVdiskKeychainAccessToken];
    [archiver encodeObject:_refreshToken forKey:kVdiskKeychainRefreshToken];
    [archiver encodeDouble:_expireTime forKey:kVdiskKeychainExpireTime];
    [archiver encodeInt:_sessionType forKey:kVdiskKeychainSessionType];
    [archiver finishEncoding];
    
    [YQKeyChain setPasswordData:data forService:serviceName account:kVdiskKeychainAccountIdentity];
    
}
- (void)deleteAuthorizeDataInKeychain {
    
//    self.sinaUserID = nil;
    self.accessToken = nil;
    self.refreshToken = nil;
    self.userID = nil;
    self.expireTime = 0.0f;
    
//    if (_sessionType == kVdiskSessionTypeWeiboAccessToken) {
//        
//        _sinaWeibo.accessToken = nil;
//        _sinaWeibo.expirationDate = nil;
//        _sinaWeibo.userID = nil;
//        _sinaWeibo.refreshToken = nil;
//    }
//    
    NSString *serviceName = [[self urlSchemeString] stringByAppendingString:kVdiskKeychainServiceNameSuffix];
    
    [YQKeyChain deletePasswordForService:serviceName account:kVdiskKeychainAccountIdentity];
}


-(NSString *)urlSchemeString
{
    return [NSString stringWithFormat:@"%@%@", kVdiskURLSchemePrefix, self.appkey];
}

-(void)linkWithSessionType:(VdiskSessionType)sessionType
{
    _sessionType = sessionType;
    [self link];
}

-(void)link
{
    if ([self isLinked] && ![self isExpired]) {
        if ([self.delegate respondsToSelector:@selector(sessionAlreadyLinked:)]) {
            [self.delegate sessionAlreadyLinked:self];
            
        }
        if (_isUserExclusive) {
            return;
        }
    }
    VdiskAuthorize *auth = [[VdiskAuthorize alloc]initWithAppKey:self.appkey appSecret:self.appSecret];
    [auth setDelegate:self];
    self.authorize = auth;

    if([self.redirectURL length] > 0)
    {
        [self.authorize setRedirectURI:self.redirectURL];
    }else{
        [self.authorize setRedirectURI:@"http://"];
    }

    [self.authorize startAuthorize];

}

-(BOOL)isExpired
{
    if ([[NSDate date] timeIntervalSince1970] > self.expireTime) {
        if (!self.refreshToken) {
            [self deleteAuthorizeDataInKeychain];
        }
        return YES;
    }
    return NO;
}

#pragma mark -VdiskAuthorizeDelegate Methods
- (void)authorize:(VdiskAuthorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken userID:(NSString *)userID expiresIn:(NSInteger)seconds
{
    
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
//    self.sinaUserID = [NSString stringWithFormat:@"%@", userID];
    self.userID = @"0";
    self.expireTime = seconds;
//    
//    self.restEngine = [[VdiskRestEngine alloc]initWithToken:self.accessToken baseURL:kVdiskAPIHost];
//    [self.restEngine loadAccountInfo];
//    YQRestClient *client = [[YQRestClient alloc]initWithToken:self.accessToken baseURL:kVdiskAPIHost];
//    
//    [client loadAccountInfo];
    
    VDiskClient *client = [[VDiskClient alloc]initWithSession:self];
    client.delegate = self;
    [client  loadAccountInfo];
}


#pragma mark -VDiskClientDelegate
-(void)restClient:(VDiskClient *)client loadedAccountInfo:(AccountInfo *)info
{
    self.userID = info.userId;
    [self saveAuthorizeDataToKeychain];
    
    if ([_delegate respondsToSelector:@selector(sessionLinkedSuccess:)]) {
        
        [_delegate sessionLinkedSuccess:self];
    }
    
}

@end

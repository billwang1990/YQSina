//
//  VDiskClient.m
//  YQSina
//
//  Created by niko on 13-6-5.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import "VDiskClient.h"
#import <AFJSONRequestOperation.h>

@implementation AFClient

+(AFClient *)sharedClient
{
    static AFClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AFClient alloc]initWithBaseURL:[NSURL URLWithString:kVdiskAPIHost]];
    });
    return instance;
}

-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    return self;
}

@end

@implementation VDiskClient

-(id)initWithSession:(YQVdiskSession *)session
{
    if (session == nil) {
        return nil;
    }
    if (self = [super init])
    {
        _session = session;
        _token = session.accessToken;
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    return self;
}


-(void)loadAccountInfo
{   
    BOOL needSign = (![self.session isLinked] || [self.session isExpired]);
    
    if (![self.session isLinked] && !needSign)
        return;
    
    AFClient *client = [AFClient sharedClient];
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth2 %@", self.token]];
    
    [client getPath:ACCOUNT_INFO parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON){
        
        AccountInfo *account = [[AccountInfo alloc]initWithDictionary:JSON];
        
        if ([self.delegate respondsToSelector:@selector(restClient:loadedAccountInfo:)]) {
            [self.delegate restClient:self loadedAccountInfo:account];
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end

//
//  VDiskClient.h
//  YQSina
//
//  Created by niko on 13-6-5.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworkActivityIndicatorManager.h>
#import <AFHTTPClient.h>
#import "YQVdiskSession.h"
#import "AccountInfo.h"

@class VDiskClient;

@protocol VDiskClientDelegate <NSObject>

- (void)restClient:(VDiskClient *)client loadedAccountInfo:(AccountInfo *)info;

@end

@interface AFClient : AFHTTPClient

+ (AFClient *)sharedClient;

@end

@interface VDiskClient : NSObject

@property (nonatomic) NSString *token;
@property (nonatomic) NSString *url;
@property (nonatomic) YQVdiskSession *session;
@property (nonatomic, weak)  id<VDiskClientDelegate> delegate;


-(id)initWithSession: (YQVdiskSession*)session;

 
-(void)loadAccountInfo;


@end

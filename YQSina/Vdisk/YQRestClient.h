//
//  YQRestClient.h
//  YQSina
//
//  Created by niko on 13-6-5.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPClient.h>
#import <RKObjectManager.h>
#import <RKObjectMapping.h>
#import <RKResponseDescriptor.h>
#import <RKMIMETypes.h>

@interface YQRestClient : NSObject

@property (nonatomic) NSString *token;
@property (nonatomic) NSString *url;
@property (nonatomic) AFHTTPClient *client;

-(id)initWithToken: (NSString *)token baseURL:(NSString *)url;

-(void)loadAccountInfo;

@end

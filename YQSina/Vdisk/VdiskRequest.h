//
//  VdiskRequest.h
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VdiskRequestDelegate;

@interface VdiskRequest : NSObject<NSURLConnectionDelegate>

@property (nonatomic) NSString *urlString;
@property (nonatomic) NSString *httpMethod;
@property (nonatomic) NSDictionary *params;
@property (nonatomic) NSDictionary *httpHeaderFileds;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic) NSMutableURLRequest *request;
@property (nonatomic, weak) id<VdiskRequestDelegate> delegate;

+(VdiskRequest *)requestWithURL:(NSString *)urlString httpMethod:(NSString*)httpMethod params:(NSDictionary *)params httpHeaderFields:(NSDictionary *)httpHeaderFields delegate:(id<VdiskRequestDelegate>)delegate;


+ (VdiskRequest *)requestWithAccessToken:(NSString *)accessToken
                                     url:(NSString *)url
                              httpMethod:(NSString *)httpMethod
                                  params:(NSDictionary *)params
                        httpHeaderFields:(NSDictionary *)httpHeaderFields
                                delegate:(id<VdiskRequestDelegate>)delegate;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

-(void)disconnect;
-(void)connect;

@end

#pragma mark -
#pragma mark -VdiskRequestDelegate

@protocol VdiskRequestDelegate <NSObject>

@optional

- (void)request:(VdiskRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;

- (void)request:(VdiskRequest *)request didReceiveRawData:(NSData *)data;

- (void)request:(VdiskRequest *)request didFailWithError:(NSError *)error;

- (void)request:(VdiskRequest *)request didFinishLoadingWithResult:(id)result;

@end




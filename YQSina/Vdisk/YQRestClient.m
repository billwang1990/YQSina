//
//  YQRestClient.m
//  YQSina
//
//  Created by niko on 13-6-5.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import "YQRestClient.h"
#import "AccountInfo.h"
#import <RestKit/RestKit.h>

@implementation YQRestClient

-(id)initWithToken:(NSString *)token baseURL:(NSString *)url
{
    if (self = [super init]) {
        _token = token;
        _url = url;
        
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        // Initialize HTTPClient
        NSURL *baseURL = [NSURL URLWithString:@"https://api.weipan.cn/2"];
        AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        
        // HACK: Set User-Agent to Mac OS X so that Twitter will let us access the Timeline
        [client setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]]];
        
        //we want to work with JSON-Data 
        [client setParameterEncoding:AFJSONParameterEncoding];
        [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];

        [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth2 %@", token]];
        
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
        // Initialize RestKit
        RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        
        // Setup our object mappings
        RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[AccountInfo class]];
        [userMapping addAttributeMappingsFromDictionary:@{
         @"uid" : @"uid",
         @"sina_uid" : @"sina_uid",
         @"quota_info" : @"quatoquota_info_info"
         }];
        
        
        // Register our mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
        [objectManager addResponseDescriptor:responseDescriptor];
        


    }
    return self;
}

-(void)loadAccountInfo
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager getObjectsAtPath:ACCOUNT_INFO
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSArray* statuses = [mappingResult array];
                                NSLog(@"Loaded statuses: %@", statuses);
 
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                message:[error localizedDescription]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                                NSLog(@"Hit error: %@", error);
                            }];

}

@end

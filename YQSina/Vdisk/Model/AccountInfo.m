//
//  AccountInfo.m
//  YQSina
//
//  Created by niko on 13-6-5.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import "AccountInfo.h"

@implementation AccountInfo

-(id)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        if ([dict objectForKey:@"quota_info"]) {
            _quota = [[VdiskQuota alloc]initWithDictionary:[dict objectForKey:@"quota_info"]];
        }
        
        if ([[dict objectForKey:@"uid"] isKindOfClass:[NSNumber class]]) {
            
            _userId = [[dict objectForKey:@"uid"] stringValue];
            
        } else {
            
            _userId = [dict objectForKey:@"uid"];
        }
        
        if ([[dict objectForKey:@"sina_uid"] isKindOfClass:[NSNumber class]]) {
            
            _sinaUserId = [[dict objectForKey:@"sina_uid"] stringValue] ;
            
        } else {
            
            _sinaUserId = [dict objectForKey:@"sina_uid"];
        }
        
    }
    return self;    
}
 

@end

//
//  AccountInfo.h
//  YQSina
//
//  Created by niko on 13-6-5.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VdiskQuota.h"

@interface AccountInfo : NSObject

- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, readonly) VdiskQuota *quota;
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *sinaUserId;

@end

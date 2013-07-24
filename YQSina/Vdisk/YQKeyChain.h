//
//  YQKeyChain.h
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface YQKeyChain : NSObject

/** Error codes that can be returned in NSError objects. */
typedef enum {
	/** No error. */
	VdiskKeychainErrorNone = noErr,
	
	/** Some of the arguments were invalid. */
	VdiskKeychainErrorBadArguments = -1001,
	
	/** There was no password. */
	VdiskKeychainErrorNoPassword = -1002,
	
	/** One or more parameters passed internally were not valid. */
	VdiskKeychainErrorInvalidParameter = errSecParam,
	
	/** Failed to allocate memory. */
	VdiskKeychainErrorFailedToAllocated = errSecAllocate,
	
	/** No trust results are available. */
	VdiskKeychainErrorNotAvailable = errSecNotAvailable,
	
	/** Authorization/Authentication failed. */
	VdiskKeychainErrorAuthorizationFailed = errSecAuthFailed,
	
	/** The item already exists. */
	VdiskKeychainErrorDuplicatedItem = errSecDuplicateItem,
	
	/** The item cannot be found.*/
	VdiskKeychainErrorNotFound = errSecItemNotFound,
	
	/** Interaction with the Security Server is not allowed. */
	VdiskKeychainErrorInteractionNotAllowed = errSecInteractionNotAllowed,
	
	/** Unable to decode the provided data. */
	VdiskKeychainErrorFailedToDecode = errSecDecode
} VdiskKeychainErrorCode;

+ (NSData *)passwordDataForService:(NSString *)service account:(NSString *)account;

+ (BOOL)deletePasswordForService:(NSString *)service account:(NSString *)account;
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)service account:(NSString *)account;
 
@end

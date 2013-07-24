//
//  VdiskRequest.m
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import "VdiskRequest.h"
#import "VdiskUtil.h"
#import "VdiskError.h"


@interface VdiskRequest ()

- (void)handleResponseData:(NSData *)data;

@end

@implementation VdiskRequest

+(VdiskRequest *)requestWithURL:(NSString *)urlString httpMethod:(NSString *)httpMethod params:(NSDictionary *)params httpHeaderFields:(NSDictionary *)httpHeaderFields delegate:(id<VdiskRequestDelegate>)delegate
{
    VdiskRequest *request = [[VdiskRequest alloc]init];
    request.urlString = urlString;
    request.params = params;
    request.httpMethod = httpMethod;
    request.httpHeaderFileds = httpHeaderFields;
    request.delegate = delegate;

    return request;
}

+(VdiskRequest *)requestWithAccessToken:(NSString *)accessToken url:(NSString *)url httpMethod:(NSString *)httpMethod params:(NSDictionary *)params httpHeaderFields:(NSDictionary *)httpHeaderFields delegate:(id<VdiskRequestDelegate>)delegate
{
    NSMutableDictionary *httpHeaderField = [NSMutableDictionary dictionaryWithDictionary:httpHeaderFields];
    
    [httpHeaderField setObject:[NSString stringWithFormat:@"OAuth2 %@", accessToken] forKey:@"Authorization"];
    
    return [VdiskRequest requestWithURL:url httpMethod:httpMethod params:params httpHeaderFields:httpHeaderFields delegate:delegate];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    
    if (![httpMethod isEqualToString:@"GET"] || !params || [params count] < 1) {
        
        return baseURL;
    }
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [VdiskRequest stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
    
}

+(NSString *)stringFromDictionary:(NSDictionary*)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [dict keyEnumerator]) {
        
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]])) {
            
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

- (void)disconnect {
    
    self.responseData = nil;
    self.params = nil;
}

- (void)connect
{
    
    self.responseData = [[NSMutableData alloc]init];
    
    NSString *urlString = [VdiskRequest serializeURL:self.urlString params:self.params httpMethod:self.httpMethod];
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.request setHTTPMethod:self.httpMethod];
    
    if ([self.httpMethod isEqualToString:@"POST"]) {
        NSMutableString *postString = [[NSMutableString alloc]init];
        for (NSString *key in [self.params keyEnumerator]) {
            [postString appendFormat:@"%@=%@&", key, [self.params objectForKey:key]];

        }
        NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        [self.request setHTTPBody:data];
    }
    
    for (NSString *key in [self.httpHeaderFileds keyEnumerator])
    {
        [self.request addValue:key forHTTPHeaderField:[self.httpHeaderFileds objectForKey:key]];
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:self.request delegate:self];
    [connection start];
}

- (void)failedWithError:(NSError *)error {
    
    
	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        
		[_delegate request:self didFailWithError:error];
	}
}

#pragma mark- private method
-(void)handleResponseData:(NSData *)data
{
    if ([self.delegate respondsToSelector:@selector(request:didReceiveRawData:)]) {
        
        [self.delegate request:self didReceiveRawData:data];
    }
    NSError *error = nil;
    id result = [self parseJSONData:data error:&error];
    
    if(error)
    {
        [self failedWithError:error];
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
            
            [_delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
		}
    }
    
}

- (id)parseJSONData:(NSData*)data error:(NSError**)error
{
    NSError *jsonErr = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonErr];

    if (jsonErr) {
        if (error != nil) {
            *error = [self errorWithCode:kVdiskErrorInvalidResponse userInfo:nil];
        }
    }
    
    if ([result objectForKey:@"error_code"] != nil || [result objectForKey:@"code"] != nil) {
        
        if (error != nil) {
            
            if ([result objectForKey:@"error_code"]) {
                
                *error = [self errorWithCode:[[result objectForKey:@"error_code"] intValue] userInfo:result];
            }
            
            if ([result objectForKey:@"code"] != nil) {
                
                *error = [self errorWithCode:[[result objectForKey:@"code"] intValue] userInfo:result];
            }
        }
    }

    
    return result;
    
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    
    return [NSError errorWithDomain:@"VdiskSDKErrorDomain" code:code userInfo:userInfo];
}

#pragma mark - urlconnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;

    NSLog(@"%@",[res allHeaderFields]);
 
}

//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];    
}

//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc]initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
    
    NSData *data = [[NSData alloc]initWithData:self.responseData];
  
    [self handleResponseData:data];
      
    self.responseData = nil;
    self.request = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.responseData = nil;
    self.request = nil;
    
}



@end

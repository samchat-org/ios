//
//  SAMCDataPostSerializer.h
//  Pods
//
//  Created by HJ on 8/16/16.
//
//

#import <AFNetworking/AFNetworking.h>

@interface SAMCDataPostSerializer : AFHTTPRequestSerializer

@property (nonatomic, assign) NSJSONWritingOptions writingOptions;

+ (instancetype)serializerWithWritingOptions:(NSJSONWritingOptions)writingOptions;

@end

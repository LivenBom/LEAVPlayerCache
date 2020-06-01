//
//  RequestCacheManager.h
//  MSAVPlayer
//
//  Created by Liven on 2020/5/28.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LERequestContentInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**

规则：一个视频url对应一个CacheManager对象

职能：
1、receiveData 保存本地
2、读取本地Data
3、将loadingRequest请求的range，对比本地缓存情况，分割成若干个fragment

*/


@import AVFoundation;
@class LERequestFragment;

@interface LERequestCacheManager : NSObject
@property (nonatomic, copy  , readonly) NSURL *url;
@property (nonatomic, strong, readwrite) LERequestContentInfo *contentInfo;

/// 初始化
/// @param url url
- (instancetype)initWithRequestURL:(NSURL *)url;


/// 对比loadingRequest的请求范围与本地已缓存的情况，将range切割成若干的fragment
/// @param range range
- (NSArray <LERequestFragment *>*)calculateRangeForRange:(NSRange)range;


/// 保存receiveData
/// @param data receiveData
/// @param range range
- (void)writeData:(NSData *)data range:(NSRange)range error:(NSError **)error;


/// 获取本地缓存data
/// @param range range
- (NSData *)cacheDataForRange:(NSRange)range error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

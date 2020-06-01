//
//  ResourceLoader.h
//  MSAVPlayer
//
//  Created by Liven on 2020/5/28.
//  Copyright © 2020 Liven. All rights reserved.
//

/**
 规则：一个视频对应一个Loader
 
 职能：是缓存器cacheManger 与 视频URL 的容器，对两者统一管理
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@import AVFoundation;

@interface LEResourceLoader : NSObject

/// 初始化
/// @param url 不带customScheme的url
- (instancetype)initWithURL:(NSURL *)url;


/// 添加loadingRequest
/// @param loadingRequest loadingRequest
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest;


/// 移除loadingRequest
/// @param loadingRequest loadingRequest
- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest;

@end

NS_ASSUME_NONNULL_END

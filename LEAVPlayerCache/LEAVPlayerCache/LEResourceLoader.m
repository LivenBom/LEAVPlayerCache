//
//  ResourceLoader.m
//  MSAVPlayer
//
//  Created by Liven on 2020/5/28.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LEResourceLoader.h"
#import "LERequestCacheManager.h"
#import "LERequestDowndloader.h"

@interface LEResourceLoader()
@property (nonatomic, strong) NSURL *originURL;
/* 下载模块 **/
@property (nonatomic, strong) NSMutableArray<LERequestDowndloader *> *downloaders;
/* 缓存模块 **/
@property (nonatomic, strong) LERequestCacheManager *cacheManager;
@end


@implementation LEResourceLoader

/// 初始化
/// @param url 不带customScheme的url
- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _originURL = url;
        _downloaders = [NSMutableArray array];
        _cacheManager = [[LERequestCacheManager alloc]initWithRequestURL:url];
    }
    return self;
}


/// 添加loadingRequest
/// @param loadingRequest loadingRequest
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    LERequestDowndloader *downloader = [LERequestDowndloader startDownLoadWithLoadingRequest:loadingRequest cacheFielManager:_cacheManager];
    [self.downloaders addObject:downloader];
}


/// 移除loadingRequest
/// @param loadingRequest loadingRequest
- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"取消下载");
    __block LERequestDowndloader *downloader = nil;
    [self.downloaders enumerateObjectsUsingBlock:^(LERequestDowndloader * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.loadingRequest == loadingRequest) {
            downloader = obj;
            *stop = YES;
        }
    }];
    
    if (downloader) {
        [downloader cancle];
        [self.downloaders removeObject:downloader];
    }
}

@end

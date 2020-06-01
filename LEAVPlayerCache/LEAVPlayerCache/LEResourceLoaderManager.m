//
//  ResourceLoaderManager.m
//  MSAVPlayer
//
//  Created by Liven on 2020/5/28.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LEResourceLoaderManager.h"
#import "LEResourceLoader.h"

#define kCustomScheme @"scheme"

@interface LEResourceLoaderManager()<AVAssetResourceLoaderDelegate>
@property (nonatomic, strong) NSMutableDictionary <NSString *,LEResourceLoader *> *loaders;
@end

@implementation LEResourceLoaderManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _loaders = [NSMutableDictionary dictionary];
    }
    return self;
}


- (AVPlayerItem *)playerItemWithURL:(NSURL *)url {
    if (!url) return nil;
    
    NSURL *assetURL = [self customSchemeWithURL:url];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    [urlAsset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    if ([playerItem respondsToSelector:@selector(setCanUseNetworkResourcesForLiveStreamingWhilePaused:)]) {
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
    }
    return playerItem;
}


/// 拼接自定义的scheme
/// @param url url
- (NSURL *)customSchemeWithURL:(NSURL *)url {
    NSURL *assetURL = [NSURL URLWithString:[kCustomScheme stringByAppendingString:url.absoluteString]];
    return assetURL;
}


/// 获取不带customScheme的url
/// @param loadingRequest loadingRequest
- (NSString *)orginRequestURLStrWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *resourceURL = loadingRequest.request.URL;
    NSString *originStr = resourceURL.absoluteString;
    if ([originStr hasPrefix:kCustomScheme]) {
        originStr = [originStr stringByReplacingOccurrencesOfString:kCustomScheme withString:@""];
    }
    return originStr;
}


#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *resourceURL = loadingRequest.request.URL;
    if ([resourceURL.absoluteString hasPrefix:kCustomScheme]) {
        // 获取原请求URL
        NSString *originStr = [resourceURL.absoluteString stringByReplacingOccurrencesOfString:kCustomScheme withString:@""];
        NSURL *originURL = [NSURL URLWithString:originStr];
        
        // 一个视频对应一个Loader
        LEResourceLoader *loader = [self.loaders objectForKey:originStr];
        if (loader == nil) {
            loader = [[LEResourceLoader alloc]initWithURL:originURL];
            [self.loaders setObject:loader forKey:originStr];
        }
        
        // 保存管理loadingRequest
        [loader addLoadingRequest:loadingRequest];
        return YES;
    }
    
    return NO;
}


- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    LEResourceLoader *loader = [self.loaders objectForKey:[self orginRequestURLStrWithLoadingRequest:loadingRequest]];
    [loader removeLoadingRequest:loadingRequest];
}


@end

//
//  ResourceLoaderManager.h
//  MSAVPlayer
//
//  Created by Liven on 2020/5/28.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 职能：
    1. 根据URL创建AVPlayerItem ，并设置resourceLoader的delegate
 */

@import AVFoundation;

@interface LEResourceLoaderManager : NSObject

- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

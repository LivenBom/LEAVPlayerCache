//
//  RequestContentInfo.h
//  MSAVPlayer
//
//  Created by Liven on 2020/5/27.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 规则：一个视频url对应一个RequestContentInfo对象
 归档位置：Tmp文件夹中的mediaCache，以.archive为后缀
 
 职能：
 1、存储视频url资源的基本信息，比如文件格式、文件长度
 2、存储已下载的range片段
 */

@class LERequestFragment;

@interface LERequestContentInfo : NSObject<NSSecureCoding>

@property (nonatomic, copy  ) NSString *contentType;
@property (nonatomic, assign) BOOL  byteRangeAccessSupported;
@property (nonatomic, assign) long long  contentLength;

@property (nonatomic, assign) BOOL  isCompleteDownload;

/// 快速创建RequestContentInfo
/// @param filePath filePath
+ (instancetype)contentInfoWithFilePath:(NSString *)filePath;


/// 保存已下载数据的range
/// @param range range
- (void)addReceiveDataRange:(NSRange)range;


/// 已缓存的ranges
- (NSArray *)cachedDataRanges;

@end

NS_ASSUME_NONNULL_END

//
//  RequestCacheManager.m
//  MSAVPlayer
//
//  Created by Liven on 2020/5/28.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LERequestCacheManager.h"
#import "LERequestFragment.h"

#define kMediaCacheDir @"mediaCache"
static NSInteger const kPackageLength = 204800; // 200kb per package

@interface LERequestCacheManager()
@property (nonatomic, copy  , readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSFileHandle *readFileHandle;
@property (nonatomic, strong, readwrite) NSFileHandle *writeFileHandle;
@end

@implementation LERequestCacheManager

/// 初始化
/// @param url url
- (instancetype)initWithRequestURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        [self configCacheFile];
    }
    return self;
}


- (void)configCacheFile {
    // 请求路径
    NSString *urlStr = self.url.absoluteString;
    // 文件名
    NSString *hashStr = [NSString stringWithFormat:@"%lu",(unsigned long)urlStr.hash];
    NSString *fileName = [hashStr stringByAppendingPathExtension:self.url.pathExtension];
    // 设置保存路径
    NSString *fileDir = [NSTemporaryDirectory() stringByAppendingPathComponent:kMediaCacheDir];
    NSString *filePath = [fileDir stringByAppendingPathComponent:fileName];
    
    // 创建videoTmpDir文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:fileDir]) {
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (!isExist) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    self.writeFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    self.readFileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    
    self.contentInfo = [LERequestContentInfo contentInfoWithFilePath:filePath];
}


/// 对比loadingRequest的请求范围与本地已缓存的情况，将range切割成若干的fragment
/// 这里添加里一个缓存数据片段的单位kPackageLength，将比较长的数据切割成若干的片段，对于IO性能是比较好的
/// 但kPackageLength也不能定义的过于小，否则会有反作用
/// @param range range
- (NSArray <LERequestFragment *>*)calculateRangeForRange:(NSRange)range {
    NSArray *cachedFragments = [self.contentInfo cachedDataRanges];
    NSMutableArray *resultFragments = [NSMutableArray array];
    if (range.length == 0 || range.location == NSNotFound) {
        return [resultFragments copy];
    }
    
    NSInteger endOffset = range.location + range.length;
    [cachedFragments enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange cacheFragment = NSRangeFromString(obj);
        // 求交集,有交集则表示range范围内有一部分本地是有缓存的
        NSRange intersectionRange = NSIntersectionRange(range, cacheFragment);
        if (intersectionRange.length > 0) {
            NSInteger package = intersectionRange.length / kPackageLength;
            for (NSInteger i = 0; i<= package; i++) {
                NSInteger offset = i * kPackageLength;
                NSInteger offsetLocation = intersectionRange.location + offset;
                NSInteger maxLocation = intersectionRange.location + intersectionRange.length;
                NSInteger length = (offsetLocation + kPackageLength) > maxLocation ? (maxLocation - offsetLocation) : kPackageLength;
                
                LERequestFragment *fragment = [[LERequestFragment alloc]initWithModelType:RangeFragmentTypeLocal requestRange:NSMakeRange(offsetLocation, length)];
                [resultFragments addObject:fragment];
            }
        }
        else if (cacheFragment.location >= endOffset) {
            *stop = YES;
        }
        
    }];
    
    
    if (resultFragments.count == 0) {
        // 与本地缓存没有交集，表示请求的rang没有缓存数据，需要发起服务器请求获取数据
        LERequestFragment *fragment = [[LERequestFragment alloc]initWithModelType:RangeFragmentTypeRemote requestRange:range];
        [resultFragments addObject:fragment];
    }
    else {
        NSMutableArray *localRemoteFragments = [NSMutableArray array];
        [resultFragments enumerateObjectsUsingBlock:^(LERequestFragment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange fragmentRange = obj.range;
            // 最开端的片段
            if (idx == 0) {
                if (range.location < fragmentRange.location) {
                    LERequestFragment *fragment = [LERequestFragment new];
                    fragment.modelType = RangeFragmentTypeRemote;
                    fragment.range = NSMakeRange(range.location, fragmentRange.location - range.location);
                    [localRemoteFragments addObject:fragment];
                }
                
                [localRemoteFragments addObject:obj];
            }
            else {
                LERequestFragment *lastFragment = [localRemoteFragments lastObject];
                NSInteger lastOffset = lastFragment.range.location + lastFragment.range.length;
                if (fragmentRange.location > lastOffset) {
                    LERequestFragment *fragment = [LERequestFragment new];
                    fragment.modelType = RangeFragmentTypeRemote;
                    fragment.range = NSMakeRange(lastOffset, fragmentRange.location - lastOffset);
                    [localRemoteFragments addObject:fragment];
                }
                [localRemoteFragments addObject:obj];
            }
            
            
            // 最尾端的片段
            if (idx == resultFragments.count - 1) {
                NSInteger localEndOffset = fragmentRange.location + fragmentRange.length;
                if (endOffset > localEndOffset) {
                    LERequestFragment *fragment = [LERequestFragment new];
                    fragment.modelType = RangeFragmentTypeRemote;
                    fragment.range = NSMakeRange(localEndOffset, endOffset - localEndOffset);
                    [localRemoteFragments addObject:fragment];
                }
            }
            
        }];
        
        resultFragments = localRemoteFragments;
    }
    
    return [resultFragments copy];
}


/// 保存receiveData
/// @param data receiveData
/// @param range range
- (void)writeData:(NSData *)data range:(NSRange)range error:(NSError **)error {
    @synchronized (self.writeFileHandle) {
        @try {
            NSLog(@"保存缓存 %@",NSStringFromRange(range));
            [self.writeFileHandle seekToFileOffset:range.location];
            [self.writeFileHandle writeData:data];
            [self.contentInfo addReceiveDataRange:range];
        } @catch (NSException *exception) {
            NSLog(@"write to file error");
            *error = [NSError errorWithDomain:exception.name code:206 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        } @finally {
            
        }
    }
}


/// 获取本地缓存data
/// @param range range
- (NSData *)cacheDataForRange:(NSRange)range error:(NSError **)error {
    @synchronized (self.readFileHandle) {
        @try {
            [self.readFileHandle seekToFileOffset:range.location];
            NSData *data = [self.readFileHandle readDataOfLength:range.length];
            return data;
        } @catch (NSException *exception) {
            NSLog(@"read cached data error : %@",exception);
            *error = [NSError errorWithDomain:exception.name code:204 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        } @finally {
            
        }
    }
    return nil;
}

@end

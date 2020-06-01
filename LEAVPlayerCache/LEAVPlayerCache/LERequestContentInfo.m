//
//  RequestContentInfo.m
//  MSAVPlayer
//
//  Created by Liven on 2020/5/27.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LERequestContentInfo.h"

#define kContentLength @"contentLength"
#define kByteRangeAccessSupported @"byteRangeAccessSupported"
#define kContentType @"contentType"
#define kFragments @"fragmengs"

@interface LERequestContentInfo()
@property (nonatomic, copy  ) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *fragmengs;
@end


@implementation LERequestContentInfo

/// 快速创建RequestContentInfo
/// @param filePath filePath
+ (instancetype)contentInfoWithFilePath:(NSString *)filePath {
    filePath = [filePath stringByReplacingOccurrencesOfString:filePath.pathExtension withString:@"archive"];
    
    LERequestContentInfo *contentInfo;
    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        contentInfo = [NSKeyedUnarchiver unarchivedObjectOfClass:[LERequestContentInfo class] fromData:data error:&error];
    }else{
        contentInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    
    if (!contentInfo) {
        contentInfo = [[LERequestContentInfo alloc]init];
    }
    contentInfo.filePath = filePath;
    return contentInfo;
}


/// 保存已下载数据的range
/// @param range range
- (void)addReceiveDataRange:(NSRange)range {
    if (range.location == NSNotFound || range.length == 0) {
        return;
    }
    @synchronized (self.fragmengs) {
        [self.fragmengs addObject:NSStringFromRange(range)];
        [self save];
    }
    
}


/// 已缓存的ranges
- (NSArray *)cachedDataRanges {
    return [self.fragmengs copy];
}


/// 归档
- (void)save {
    @synchronized (self.fragmengs) {
        BOOL isSuccess = YES;
        if (@available(iOS 11.0, *)) {
            NSError *error;
            NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:&error];
            if (!error) {
                isSuccess = [archivedData writeToFile:self.filePath atomically:YES];
            }else{
                isSuccess = NO;
            }
        }
        else{
            isSuccess = [NSKeyedArchiver archiveRootObject:self toFile:self.filePath];
        }
        
        // 如果保存失败，则遗弃
        if (!isSuccess) {
            [self.fragmengs removeLastObject];
        }
    }
}


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt64:self.contentLength forKey:kContentLength];
    [coder encodeBool:self.byteRangeAccessSupported forKey:kByteRangeAccessSupported];
    [coder encodeObject:self.contentType forKey:kContentType];
    [coder encodeObject:self.fragmengs forKey:kFragments];
}


///  tips: （1）数组解档的时候，一定要用decodeObjectOfClass:forKey:的方法，确认解档的是数组，否则会解档失败
///      （2）NSRange 转化为NSValue 存放在数组中，解档也是会有问题的，所以这里是将NSRange转为NString
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _contentLength = [coder decodeInt64ForKey:kContentLength];
        _contentType = [coder decodeObjectOfClass:NSString.class forKey:kContentType];
        _byteRangeAccessSupported = [coder decodeBoolForKey:kByteRangeAccessSupported];
        _fragmengs = [coder decodeObjectOfClass:NSMutableArray.class forKey:kFragments];
    }
    return self;
}


+ (BOOL)supportsSecureCoding {
    return YES;
}


#pragma mark - Getter
- (NSMutableArray *)fragmengs {
    if (!_fragmengs) {
        _fragmengs = [NSMutableArray array];
    }
    return _fragmengs;
}


@end

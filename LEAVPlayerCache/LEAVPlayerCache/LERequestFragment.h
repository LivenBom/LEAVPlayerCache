//
//  RangeModel.h
//  MSAVPlayer
//
//  Created by Liven on 2020/5/27.
//  Copyright © 2020 Liven. All rights reserved.
//  请求片段

#import <Foundation/Foundation.h>

/**
 职能：请求的range与本地缓存的数据，切割出来的range封装成Model
 
 */

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,RangeFragmentType) {
    RangeFragmentTypeLocal,
    RangeFragmentTypeRemote,
};


@interface LERequestFragment : NSObject
@property (nonatomic, assign, readwrite) RangeFragmentType modelType;
@property (nonatomic, assign, readwrite) NSRange range;

- (instancetype)initWithModelType:(RangeFragmentType)modelType requestRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END

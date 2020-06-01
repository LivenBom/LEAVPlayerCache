//
//  RangeModel.m
//  MSAVPlayer
//
//  Created by Liven on 2020/5/27.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LERequestFragment.h"

@implementation LERequestFragment
- (instancetype)initWithModelType:(RangeFragmentType)modelType requestRange:(NSRange)range {
    self = [super init];
    if (self) {
        _modelType = modelType;
        _range = range;
    }
    return self;
}
@end

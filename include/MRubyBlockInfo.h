//
//  MRubyBlockInfo.h
//  MRuby
//
//  Created by yoshida on 2014/01/09.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRuby;
@class MRubyValue;

#ifndef _mruby_block
#define _mruby_block
typedef NSObject* (^MRubyBlock)(MRubyValue *args);
#endif

@interface MRubyBlockInfo : NSObject {
    MRuby *mruby;
    MRubyBlock block;
}

@property (nonatomic, strong, readonly) MRuby *mruby;
@property (nonatomic, copy, readonly) MRubyBlock block;

+ (id)infoWithBlock:(MRubyBlock)block withMRuby:(MRuby *)mruby;

+ (void)push:(MRubyBlockInfo *)info;
+ (void)pop;
+ (MRubyBlockInfo *)get;

@end

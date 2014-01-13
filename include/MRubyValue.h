//
//  MRubyValue.h
//  MRuby
//
//  Created by yoshida on 2014/01/08.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRubyUtil.h"

@class MRuby;
@class MRubyValue;

#ifndef _mruby_block
#define _mruby_block
typedef NSObject* (^MRubyBlock)(MRubyValue *args);
#endif

@interface MRubyValue : NSObject {
    MRuby *mruby;
    mrb_value _self;
}

- (id)initWithObject:(NSObject *)object withMRuby:(MRuby *)mruby;
- (id)initWithValue:(mrb_value)value withMRuby:(MRuby *)mruby;

- (MRubyValue *)eval:(NSString *)code;

- (MRubyValue *)send:(NSString *)method;
- (MRubyValue *)send:(NSString *)method args:(NSArray *)args;
- (MRubyValue *)send:(NSString *)method blocks:(MRubyBlock)block;
- (MRubyValue *)send:(NSString *)method args:(NSArray *)args blocks:(MRubyBlock)block;
- (MRubyValue *)send:(NSString *)method proc:(MRubyValue *)block;
- (MRubyValue *)send:(NSString *)method args:(NSArray *)args proc:(MRubyValue *)block;

- (NSObject *)toObjc;
- (mrb_value)toMRb;

@property (nonatomic, strong, readonly) MRuby *mruby;

+ (id)valueWithObject:(NSObject *)object withMRuby:(MRuby *)mruby;

@end

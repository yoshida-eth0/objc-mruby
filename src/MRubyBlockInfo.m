//
//  MRubyBlockInfo.m
//  MRuby
//
//  Created by yoshida on 2014/01/09.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import "MRubyBlockInfo.h"
#import "MRuby.h"

// Private
@interface MRubyBlockInfo ()

@property (nonatomic, strong, readwrite) MRuby *mruby;
@property (nonatomic, copy, readwrite) MRubyBlock block;

+ (void)initStack;
+ (NSString *)key;

@end


@implementation MRubyBlockInfo
@synthesize mruby;
@synthesize block;

- (id)initWithBlock:(MRubyBlock)_block withMRuby:(MRuby *)_mruby
{
    self = [super init];
    if (self) {
        self.mruby = _mruby;
        self.block = _block;
    }
    return self;
}


#pragma mark static

+ (id)infoWithBlock:(MRubyBlock)block withMRuby:(MRuby *)mruby
{
    return [[self alloc] initWithBlock:block withMRuby:mruby];
}


#pragma mark stack

NSMutableDictionary *_dic;

+ (void)initStack
{
    if (!_dic) {
        @synchronized (self) {
            if (!_dic) {
                _dic = [NSMutableDictionary dictionary];
            }
        }
    }
}

+ (NSString *)key
{
    return [NSString stringWithFormat:@"%lu", [[NSThread currentThread] hash]];
}

+ (void)push:(MRubyBlockInfo *)info
{
    [self initStack];
    @synchronized (_dic) {
        NSMutableArray *stack = [_dic objectForKey:[self key]];
        if (!stack) {
            stack = [NSMutableArray array];
            [_dic setObject:stack forKey:[self key]];
        }
        [stack addObject:info];
    }
}

+ (void)pop
{
    @synchronized (_dic) {
        NSMutableArray *stack = [_dic objectForKey:[self key]];
        [stack removeLastObject];
    }
}

+ (MRubyBlockInfo *)get
{
    @synchronized (_dic) {
        NSMutableArray *stack = [_dic objectForKey:[self key]];
        return [stack lastObject];
    }
}

@end

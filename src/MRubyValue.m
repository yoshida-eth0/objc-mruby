//
//  MRubyValue.m
//  MRuby
//
//  Created by yoshida on 2014/01/08.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import "MRuby.h"
#import "MRubyValue.h"
#import "MRubyBlockInfo.h"
#import "MRubyUtil.h"

// Private
@interface MRubyValue ()

@property (nonatomic, strong, readwrite) MRuby *mruby;
@property (nonatomic, assign, readwrite) mrb_value _self;

@end


@implementation MRubyValue
@synthesize mruby;
@synthesize _self;

- (id)initWithObject:(NSObject *)object withMRuby:(MRuby *)_mruby
{
    return [self initWithValue:[MRubyUtil mrb:[_mruby mrb] objc2mrb:object] withMRuby:_mruby];
}

- (id)initWithValue:(mrb_value)value withMRuby:(MRuby *)_mruby
{
    self = [super init];
    if (self) {
        self.mruby = _mruby;
        self._self = value;
    }
    return self;
}


#pragma mark eval

- (MRubyValue *)eval:(NSString *)code
{
    mrb_state *mrb = [mruby mrb];
    
    NSString *procCode = [NSString stringWithFormat:@"Proc.new{%@}", code];
    mrb_value proc = [MRubyUtil mrb:mrb eval:procCode];
    
    mrb_value ret = mrb_funcall_with_block(mrb, _self, mrb_intern_cstr(mrb, "instance_eval"), 0, NULL, proc);
    [MRubyUtil mrbRaiseUncaughtException:mrb];
    
    return [[[self class] alloc] initWithValue:ret withMRuby:mruby];
}


#pragma mark send

- (MRubyValue *)send:(NSString *)method
{
    return [self send:method args:nil proc:nil];
}

- (MRubyValue *)send:(NSString *)method args:(NSArray *)args
{
    return [self send:method args:args proc:nil];
}

- (MRubyValue *)send:(NSString *)method blocks:(MRubyBlock)block
{
    return [self send:method args:nil blocks:block];
}

- (MRubyValue *)send:(NSString *)method args:(NSArray *)args blocks:(MRubyBlock)block
{
    mrb_state *mrb = [mruby mrb];
    
    mrb_value proc = mrb_nil_value();
    MRubyBlockInfo *info = nil;
    
    if (block) {
        // bridge proc
        proc = mrb_funcall(mrb, mrb_obj_value(mrb_class_get(mrb, "ObjcBridgeProc")), "new", 0);
        [MRubyUtil mrbRaiseUncaughtException:mrb];
        
        // push block info
        info = [MRubyBlockInfo infoWithBlock:block withMRuby:mruby];
        [MRubyBlockInfo push:info];
    }
    
    @try {
        // send
        return [self send:method args:args proc:[[[self class] alloc] initWithValue:proc withMRuby:mruby]];
    }
    @finally {
        // pop block info
        if (info) {
            [MRubyBlockInfo pop];
        }
    }
}

- (MRubyValue *)send:(NSString *)method proc:(MRubyValue *)block
{
    return [self send:method args:nil proc:block];
}

- (MRubyValue *)send:(NSString *)method args:(NSArray *)args proc:(MRubyValue *)block
{
    mrb_state *mrb = [mruby mrb];
    mrb_value proc = mrb_nil_value();
    
    // to proc
    if (block && !mrb_nil_p([block toMRb])) {
        proc = [[block send:@"to_proc"] toMRb];
    }
    
    // argv
    mrb_value argv[[args count]+1];
    for (int i=0; i<[args count]; i++) {
        argv[i] = [MRubyUtil mrb:mrb objc2mrb:[args objectAtIndex:i]];
    }
    
    // send
    mrb_value ret = mrb_funcall_with_block(mrb, _self, mrb_intern_cstr(mrb, [method UTF8String]), (int)[args count], argv, proc);
    [MRubyUtil mrbRaiseUncaughtException:mrb];
    
    return [[[self class] alloc] initWithValue:ret withMRuby:mruby];
}


#pragma mark convert

- (NSObject *)toObjc
{
    return [MRubyUtil mrb:[mruby mrb] mrb2objc:_self];
}

- (mrb_value)toMRb
{
    return _self;
}


#pragma mark static

+ (id)valueWithObject:(NSObject *)object withMRuby:(MRuby *)mruby
{
    return [[self alloc] initWithObject:object withMRuby:mruby];
}

@end

//
//  MRubyUtil.h
//  MRuby
//
//  Created by yoshida on 2014/01/08.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mruby.h>
#include <mruby/variable.h>
#include <mruby/array.h>
#include <mruby/hash.h>
#include <mruby/compile.h>
#include <mruby/string.h>

@class MRuby;

@interface MRubyUtil : NSObject

+ (void)mruby:(MRuby *)mruby retain:(mrb_value)obj;
+ (void)mruby:(MRuby *)mruby release:(mrb_value)obj;
+ (BOOL)isGcManagedObject:(mrb_value)obj;

+ (mrb_value)mrb:(mrb_state *)mrb eval:(NSString *)code;
+ (mrb_value)mrb:(mrb_state *)mrb eval:(NSString *)code filename:(const char *)filename;
+ (void)mrbRaiseUncaughtException:(mrb_state *)mrb;

+ (mrb_value)mrb:(mrb_state *)mrb objc2mrb:(NSObject *)o;
+ (NSObject *)mrb:(mrb_state *)mrb mrb2objc:(mrb_value)o;
+ (NSObject *)mrb:(mrb_state *)mrb mrb2objc:(mrb_value)o useNSNull:(BOOL)useNSNull;

@end

mrb_value mrb_hash_get(mrb_state *mrb, mrb_value hash, mrb_value key);
void mrb_hash_set(mrb_state *mrb, mrb_value hash, mrb_value key, mrb_value val);
mrb_value mrb_hash_delete_key(mrb_state *mrb, mrb_value hash, mrb_value key);
mrb_value mrb_get_backtrace(mrb_state*, mrb_value);

void mrb_init_objc_bridge_proc(mrb_state *mrb);
mrb_value mrb_objc_bridge_proc_initialize(mrb_state *mrb, mrb_value self);
mrb_value mrb_objc_bridge_proc_call(mrb_state *mrb, mrb_value self);

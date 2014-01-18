//
//  MRuby.m
//  MRuby
//
//  Created by yoshida on 2014/01/07.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import "MRuby.h"
#import "MRubyValue.h"
#import "MRubyUtil.h"

// Private
@interface MRuby ()

@property (nonatomic, strong, readwrite) NSMutableArray *loadPath;

@end


@implementation MRuby
@synthesize mrb;
@synthesize retainPool;
@synthesize referenceHash;
@synthesize filename;
@synthesize loadPath;

- (id)init
{
    self = [super init];
    if (self) {
        mrb = mrb_open();
        
        // define ObjcBridgeProc class
        mrb_init_objc_bridge_proc(mrb);
        
        // init retain pool
        retainPool = mrb_hash_new(mrb);
        mrb_gc_protect(mrb, retainPool);
        
        // init reference count hash
        referenceHash = mrb_hash_new(mrb);
        mrb_gc_protect(mrb, referenceHash);
        
        // set default load path
        self.loadPath = [NSMutableArray array];
        [self.loadPath addObject:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources"]];
    }
    return self;
}

- (void)dealloc
{
    if (mrb) {
        mrb_close(mrb);
        mrb = NULL;
    }
}


#pragma mark const

- (void)setConst:(NSObject *)value withKey:(NSString *)key
{
    if (!key) {
        [NSException exceptionWithName:@"KeyRequired" reason:@"key is required" userInfo:nil];
    }
    mrb_define_global_const(mrb, [key UTF8String], [MRubyUtil mrb:mrb objc2mrb:value]);
}


#pragma mark exec

- (MRubyValue *)require:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *absolutePath = filePath;
    
    // search load path
    for (NSString *_loadPath in loadPath) {
        NSString *tmpPath = [_loadPath stringByAppendingPathComponent:filePath];
        if ([manager fileExistsAtPath:tmpPath isDirectory:false]) {
            absolutePath = tmpPath;
            break;
        }
        tmpPath = [tmpPath stringByAppendingString:@".rb"];
        if ([manager fileExistsAtPath:tmpPath isDirectory:false]) {
            absolutePath = tmpPath;
            break;
        }
    }
    
    // read file
    NSError *error = nil;
    NSString *code = [NSString stringWithContentsOfFile:absolutePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSException *exc = [NSException exceptionWithName:[error localizedDescription] reason:[error localizedFailureReason] userInfo:[error userInfo]];
        [exc raise];
    }
    
    // eval
    return [self eval:code];
}

- (MRubyValue *)exec:(NSString *)filePath withArgs:(NSArray *)args
{
    [self setFilename:filePath];
    [self setConst:(args ? args : @[]) withKey:@"ARGV"];
    return [self require:filePath];
}


#pragma mark eval

- (MRubyValue *)eval:(NSString *)code
{
    mrb_value ret = [MRubyUtil mrb:mrb eval:code filename:[filename UTF8String]];
    return [[MRubyValue alloc] initWithValue:ret withMRuby:self];
}


#pragma mark convert

- (MRubyValue *)value:(NSObject *)object
{
    return [MRubyValue valueWithObject:object withMRuby:self];
}


#pragma mark static

+ (id)mruby
{
    return [[self alloc] init];
}

@end

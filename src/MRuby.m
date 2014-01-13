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
@synthesize filename;
@synthesize loadPath;

- (id)init
{
    self = [super init];
    if (self) {
        mrb = mrb_open();
        [MRubyUtil mrbInit:mrb];
        
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


#pragma mark exec

- (void)setArgv:(NSArray *)argv
{
    if (!argv) {
        argv = @[];
    }
    mrb_define_global_const(mrb, "ARGV", [MRubyUtil mrb:mrb objc2mrb:argv]);
}

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
    [self setArgv:args];
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

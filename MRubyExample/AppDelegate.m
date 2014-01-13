//
//  AppDelegate.m
//  MRubyExample
//
//  Created by tetu on 2014/01/13.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import "AppDelegate.h"
#import "MRuby.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [execScriptButton setAction:@selector(actionExecScript)];
    [evalScriptButton setAction:@selector(actionEvalScript)];
    [instanceEvalButton setAction:@selector(actionInstanceEval)];
    [callMethodChainingButton setAction:@selector(actionCallMethodChaining)];
}

/*
 * exec script
 */
- (void)actionExecScript
{
    NSLog(@"%s", __func__);
    
    MRuby *mruby = [MRuby mruby];
    @try {
        MRubyValue *fizzBuzz = [mruby exec:@"fizzbuzz.rb" withArgs:nil];
        
        NSString *result = [NSString stringWithFormat:@"[ExecScript Success]\n\n%@", [fizzBuzz toObjc]];
        [textView setString:result];
    }
    @catch (NSException *exception) {
        NSString *result = [NSString stringWithFormat:@"[ExecScript Exception]\n\n%@", [exception userInfo]];
        [textView setString:result];
    }
}

/*
 * eval script
 *
 * mean:
 *   (1..20).map{|i|i%3<1&&x=:Fizz;i%5<1?"#{x}Buzz":x||i}.map(&:to_s.to_proc)
 */
- (void)actionEvalScript
{
    NSLog(@"%s", __func__);
    
    MRuby *mruby = [MRuby mruby];
    @try {
        MRubyValue *fizzBuzz = [mruby eval:@"(1..20).map{|i|i%3<1&&x=:Fizz;i%5<1?\"#{x}Buzz\":x||i}.map(&:to_s.to_proc)"];
        
        NSString *result = [NSString stringWithFormat:@"[EvalScript Success]\n\n%@", [fizzBuzz toObjc]];
        [textView setString:result];
    }
    @catch (NSException *exception) {
        NSString *result = [NSString stringWithFormat:@"[EvalScript Exception]\n\n%@", [exception userInfo]];
        [textView setString:result];
    }
}

/*
 * range object instance_eval
 *
 * mean:
 *   (1..20).instance_eval {
 *     map{|i|i%3<1&&x=:Fizz;i%5<1?"#{x}Buzz":x||i}.map(&:to_s.to_proc)
 *   }
 */
- (void)actionInstanceEval
{
    NSLog(@"%s", __func__);
    
    MRuby *mruby = [MRuby mruby];
    @try {
        MRubyValue *fizzBuzz = [[mruby eval:@"1..20"] eval:@"map{|i|i%3<1&&x=:Fizz;i%5<1?\"#{x}Buzz\":x||i}.map(&:to_s.to_proc)"];
        
        NSString *result = [NSString stringWithFormat:@"[InstanceEval Success]\n\n%@", [fizzBuzz toObjc]];
        [textView setString:result];
    }
    @catch (NSException *exception) {
        NSString *result = [NSString stringWithFormat:@"[InstanceEval Exception]\n\n%@", [exception userInfo]];
        [textView setString:result];
    }
}

/*
 * range object call method chaining
 *
 * mean:
 *   (1..20).map {|i|
 *     i.instance_eval {
 *       i=self;i%3<1&&x=:Fizz;i%5<1?"#{x}Buzz":x||i
 *     } 
 *   }.map(&:to_s.to_proc)
 */
- (void)actionCallMethodChaining
{
    NSLog(@"%s", __func__);
    
    MRuby *mruby = [MRuby mruby];
    @try {
        MRubyValue *fizzBuzz = [[[mruby eval:@"1..20"] send:@"map" blocks:^NSObject *(MRubyValue *i) {
            return [i eval:@"i=self;i%3<1&&x=:Fizz;i%5<1?\"#{x}Buzz\":x||i"];
        }] send:@"map" proc:[mruby eval:@":to_s"]];
        
        NSString *result = [NSString stringWithFormat:@"[CallMethodChaining Success]\n\n%@", [fizzBuzz toObjc]];
        [textView setString:result];
    }
    @catch (NSException *exception) {
        NSString *result = [NSString stringWithFormat:@"[CallMethodChaining Exception]\n\n%@", [exception userInfo]];
        [textView setString:result];
    }
}

@end

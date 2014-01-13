//
//  AppDelegate.h
//  MRubyExample
//
//  Created by tetu on 2014/01/13.
//  Copyright (c) 2014年 yoshida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSButton *execScriptButton;
    IBOutlet NSButton *evalScriptButton;
    IBOutlet NSButton *instanceEvalButton;
    IBOutlet NSButton *callMethodChainingButton;
    IBOutlet NSTextView *textView;
}

- (void)actionEvalScript;
- (void)actionInstanceEval;

@property (assign) IBOutlet NSWindow *window;

@end

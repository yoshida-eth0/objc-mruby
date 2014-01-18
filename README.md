# objc-mruby

An objc-mruby is mruby wrapper for Objective-C.

## lib sources and headers

    src/
    ├── MRuby.m
    ├── MRubyBlockInfo.m
    ├── MRubyUtil.m
    └── MRubyValue.m
    include/
    ├── MRuby.h
    ├── MRubyBlockInfo.h
    ├── MRubyUtil.h
    └── MRubyValue.h

## Build example app

    $ git clone git://github.com/yoshida-eth0/objc-mruby.git
    $ cd objc-mruby
    $ git submodule init
    $ git submodule update
    $ cd mruby
    $ rake
    $ cd ..
    $ xcodebuild -project MRubyExample.xcodeproj -configuration Release
    $ open build/Release/MRubyExample.app

## Example

### exec script

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

### eval script

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

### object instance_eval

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

### object call method chaining

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

## License

MIT

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

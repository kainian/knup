//
//  main.m
//  NP_TEMPLATE_MACOS_NAME
//
//  Created by Jonathan Lee on 6/16/25.
//

#import <AppKit/AppKit.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<NSApplicationDelegate> delegate = [NSClassFromString(@"AppDelegate") new];
        NSApplication.sharedApplication.delegate = delegate;
        return NSApplicationMain(argc, argv);
    }
}

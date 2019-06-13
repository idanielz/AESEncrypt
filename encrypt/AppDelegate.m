//
//  AppDelegate.m
//  encrypt
//
//  Created by 张继东 on 2019/6/12.
//  Copyright © 2019 idanielz. All rights reserved.
//

#import "AppDelegate.h"
#import "DragView.h"
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    DragView *dv = [[DragView alloc]initWithFrame: self.window.contentView.bounds];
    [self.window.contentView addSubview:dv];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

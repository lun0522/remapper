//
//  ApplicationDelegate.m
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#import "ApplicationDelegate.h"

@implementation ApplicationDelegate {
  InputController* _inputController;
}

- (void)applicationWillFinishLaunching:(NSNotification*)notification {
  _inputController = [[InputController alloc] initWithDelegate:self];
}

#pragma mark InputControllerDelegate

- (void)inputController:(InputController*)controller didError:(NSError*)error {
  NSLog(@"Received input controller error");
}

@end

//
//  ApplicationDelegate.m
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#import "ApplicationDelegate.h"

#import "InputController.h"

@implementation ApplicationDelegate {
  InputController* _inputController;
}

- (void)applicationWillFinishLaunching:(NSNotification*)notification {
  _inputController = [InputController new];
}

@end

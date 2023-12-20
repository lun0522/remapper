//
//  ApplicationDelegate.h
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#ifndef ApplicationDelegate_h
#define ApplicationDelegate_h

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#import "InputController.h"

@interface ApplicationDelegate : NSObject <InputControllerDelegate>

- (void)applicationWillFinishLaunching:(NSNotification*)notification;

@end

#endif /* ApplicationDelegate_h */

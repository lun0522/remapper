//
//  InputController.h
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#ifndef InputController_h
#define InputController_h

#import "HIDManager.h"

// Forward declarations
@protocol InputControllerDelegate;

@interface InputController : NSObject <HIDManagerDelegate>

- (id)initWithDelegate:(id<InputControllerDelegate>)delegate;

@end

@protocol InputControllerDelegate

- (void)inputController:(InputController*)controller didError:(NSError*)error;

@end

#endif /* InputController_h */

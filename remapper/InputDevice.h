//
//  InputDevice.h
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#ifndef InputDevice_h
#define InputDevice_h

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>

@interface InputDevice : NSObject

- (id)initWithDevice:(IOHIDDeviceRef)device;
- (NSString*)uid;

@end

#endif /* InputDevice_h */

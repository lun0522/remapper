//
//  HIDManager.h
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#ifndef HIDManager_h
#define HIDManager_h

#import <IOKit/hid/IOHIDLib.h>

// Forward declarations
@protocol HIDManagerDelegate;

// Wrapper for IOKit IOHIDManager
@interface HIDManager : NSObject

- (id)initWithCriteria:(NSArray*)criteria
              delegate:(id<HIDManagerDelegate>)delegate;
- (void)start;
- (void)stop;

@end

@protocol HIDManagerDelegate

- (void)HIDManagerDidStart:(HIDManager*)manager;
- (void)HIDManagerDidStop:(HIDManager*)manager;
- (void)HIDManager:(HIDManager*)manager deviceAdded:(IOHIDDeviceRef)device;
- (void)HIDManager:(HIDManager*)manager deviceRemoved:(IOHIDDeviceRef)device;
- (void)HIDManager:(HIDManager*)manager valueChanged:(IOHIDValueRef)value;
- (void)HIDManager:(HIDManager*)manager didError:(NSError*)error;

@end

#endif /* HIDManager_h */

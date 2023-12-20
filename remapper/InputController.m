//
//  InputController.m
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#import "InputController.h"

#import <CoreVideo/CoreVideo.h>
#import <IOKit/hid/IOHIDLib.h>

#import "InputDevice.h"

@interface InputController ()

- (BOOL)createDisplayLink;
- (void)startHIDManager;

@end

@implementation InputController {
  CVDisplayLinkRef _displayLink;
  HIDManager* _HIDManager;
  NSMutableDictionary<NSString*, InputDevice*>* _inputDevices;
  id<InputControllerDelegate> _delegate;
}

- (id)initWithDelegate:(id<InputControllerDelegate>)delegate {
  if ((self = [super init]) && [self createDisplayLink]) {
    [self startHIDManager];
    _inputDevices = [NSMutableDictionary new];
    _delegate = delegate;
  }
  return self;
}

- (BOOL)createDisplayLink {
  CVReturn ret = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
  if (ret != kCVReturnSuccess) {
    NSError* error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:ret
                                     userInfo:nil];
    [_delegate inputController:self didError:error];
    NSLog(@"Failed to create DisplayLink: %@", error);
    return FALSE;
  }
  return TRUE;
}

- (void)startHIDManager {
  _HIDManager = [[HIDManager alloc] initWithCriteria:@[
    @{
      @(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
      @(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_Joystick)
    },
  ]
                                            delegate:self];
  [_HIDManager start];
}

#pragma mark HIDManagerDelegate

- (void)HIDManagerDidStart:(id)manager {
  NSLog(@"Started HID manager");
}

- (void)HIDManagerDidStop:(id)manager {
  NSLog(@"Stopped HID manager");
}

- (void)HIDManager:(id)manager deviceAdded:(IOHIDDeviceRef)deviceRef {
  InputDevice* device = [[InputDevice alloc] initWithDevice:deviceRef];
  NSString* uid = device.uid;
  if (_inputDevices[uid]) {
    NSLog(@"Cannot add duplicated device '%@'", uid);
  } else {
    _inputDevices[uid] = device;
    NSLog(@"Added device '%@'", uid);
  }
}

- (void)HIDManager:(id)manager deviceRemoved:(IOHIDDeviceRef)deviceRef {
  InputDevice* device = [[InputDevice alloc] initWithDevice:deviceRef];
  NSString* uid = device.uid;
  if (_inputDevices[uid]) {
    [_inputDevices removeObjectForKey:uid];
    NSLog(@"Removed device '%@'", uid);
  } else {
    NSLog(@"Device '%@' not found, cannot remove", uid);
  }
}

- (void)HIDManager:(HIDManager*)manager valueChanged:(IOHIDValueRef)value {
  IOHIDElementRef element = value ? IOHIDValueGetElement(value) : NULL;
  IOHIDDeviceRef deviceRef = element ? IOHIDElementGetDevice(element) : NULL;
  InputDevice* device = [[InputDevice alloc] initWithDevice:deviceRef];
  if (_inputDevices[device.uid]) {
    uint32_t usage = IOHIDElementGetUsage(element);
    NSLog(@"Input usage %u value %ld", usage, IOHIDValueGetIntegerValue(value));
  }
}

- (void)HIDManager:(HIDManager*)manager didError:(NSError*)error {
  NSLog(@"Received HID manager error");
}

@end

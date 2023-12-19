//
//  InputController.m
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#import "InputController.h"

#import <CoreVideo/CoreVideo.h>
#import <IOKit/hid/IOHIDLib.h>

@interface InputController ()

- (BOOL)createDisplayLink;
- (BOOL)setDisplayLinkOutputCallback;
- (NSError*)notifyErrorFromReturnCode:(CVReturn)code;

@end

@implementation InputController {
  CVDisplayLinkRef _displayLink;
  HIDManager* _HIDManager;
  id<InputControllerDelegate> _delegate;
}

static CVReturn updateDirectLink(CVDisplayLinkRef displayLink,
                                 const CVTimeStamp* inNow,
                                 const CVTimeStamp* inOutputTime,
                                 CVOptionFlags flagsIn, CVOptionFlags* flagsOut,
                                 void* ctxManager) {
  return kCVReturnSuccess;
}

- (id)init {
  self = [super init];
  if (self == nil || ![self createDisplayLink] ||
      ![self setDisplayLinkOutputCallback]) {
    return nil;
  }

  _HIDManager = [[HIDManager alloc] initWithCriteria:@[
    @{
      @(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
      @(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_Joystick)
    },
    @{
      @(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
      @(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_GamePad)
    },
    @{
      @(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
      @(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_MultiAxisController)
    }
  ]
                                            delegate:self];
  [_HIDManager start];

  return self;
}

- (BOOL)createDisplayLink {
  CVReturn ret = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
  NSError* error = [self notifyErrorFromReturnCode:ret];
  if (error != nil) {
    NSLog(@"Failed to create DisplayLink: %@", error);
    return FALSE;
  }
  return TRUE;
}

- (BOOL)setDisplayLinkOutputCallback {
  CVReturn ret = CVDisplayLinkSetOutputCallback(_displayLink, updateDirectLink,
                                                (__bridge void*)self);
  NSError* error = [self notifyErrorFromReturnCode:ret];
  if (error != nil) {
    NSLog(@"Failed to set callback for DisplayLink: %@", error);
    return FALSE;
  }
  return TRUE;
}

- (NSError*)notifyErrorFromReturnCode:(CVReturn)code {
  NSError* error = nil;
  if (code != kCVReturnSuccess) {
    error = [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:nil];
    [_delegate inputController:self didError:error];
  }
  return error;
}

#pragma mark HIDManagerDelegate

- (void)HIDManagerDidStart:(id)manager {
  NSLog(@"Started HID manager");
}

- (void)HIDManagerDidStop:(id)manager {
  NSLog(@"Stopped HID manager");
}

- (void)HIDManager:(id)manager deviceAdded:(IOHIDDeviceRef)device {
  NSLog(@"Device added");
}

- (void)HIDManager:(id)manager deviceRemoved:(IOHIDDeviceRef)device {
  NSLog(@"Device removed");
}

- (void)HIDManager:(HIDManager*)manager valueChanged:(IOHIDValueRef)value {
}

- (void)HIDManager:(HIDManager*)manager didError:(NSError*)error {
  NSLog(@"Received HID error");
}

@end

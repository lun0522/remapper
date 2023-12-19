//
//  HIDManager.m
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#import <Foundation/Foundation.h>

#import "HIDManager.h"

@interface HIDManager ()

- (BOOL)isRunning;

@end

@implementation HIDManager {
  NSArray* _criteria;
  id<HIDManagerDelegate> _delegate;
  IOHIDManagerRef _manager;
}

static void handleInputValue(void* ctx, IOReturn inResult, void* inSender,
                             IOHIDValueRef value) {
  HIDManager* self = (__bridge HIDManager*)ctx;
  [self->_delegate HIDManager:self valueChanged:value];
}

static void handleDeviceAdded(void* ctx, IOReturn inResult, void* inSender,
                              IOHIDDeviceRef device) {
  HIDManager* self = (__bridge HIDManager*)ctx;
  [self->_delegate HIDManager:self deviceAdded:device];
  IOHIDDeviceRegisterInputValueCallback(device, handleInputValue, ctx);
}

static void handleDeviceRemoved(void* ctx, IOReturn inResult, void* inSender,
                                IOHIDDeviceRef device) {
  HIDManager* self = (__bridge HIDManager*)ctx;
  [self->_delegate HIDManager:self deviceRemoved:device];
}

- (id)initWithCriteria:(NSArray*)criteria
              delegate:(id<HIDManagerDelegate>)delegate {
  if ((self = [super init])) {
    _criteria = criteria;
    _delegate = delegate;
  }
  return self;
}

- (void)dealloc {
  [self stop];
}

- (void)start {
  if ([self isRunning]) {
    return;
  }

  IOHIDManagerRef manager =
      IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
  IOHIDManagerSetDeviceMatchingMultiple(manager,
                                        (__bridge CFArrayRef)_criteria);
  IOReturn ret = IOHIDManagerOpen(manager, kIOHIDOptionsTypeNone);

  if (ret != kIOReturnSuccess) {
    NSError* error = [NSError errorWithDomain:NSMachErrorDomain
                                         code:ret
                                     userInfo:nil];
    IOHIDManagerClose(manager, kIOHIDOptionsTypeNone);
    CFRelease(manager);
    [_delegate HIDManager:self didError:error];
    NSLog(@"Failed to start HID manager: %@", error);
    return;
  }

  _manager = manager;
  IOHIDManagerScheduleWithRunLoop(_manager, CFRunLoopGetCurrent(),
                                  kCFRunLoopDefaultMode);
  IOHIDManagerRegisterDeviceMatchingCallback(_manager, handleDeviceAdded,
                                             (__bridge void*)self);
  IOHIDManagerRegisterDeviceRemovalCallback(_manager, handleDeviceRemoved,
                                            (__bridge void*)self);
  [_delegate HIDManagerDidStart:self];
}

- (void)stop {
  if (![self isRunning]) {
    return;
  }

  IOHIDManagerUnscheduleFromRunLoop(_manager, CFRunLoopGetCurrent(),
                                    kCFRunLoopDefaultMode);
  IOHIDManagerClose(_manager, kIOHIDOptionsTypeNone);
  CFRelease(_manager);
  _manager = NULL;
  [_delegate HIDManagerDidStop:self];
}

- (BOOL)isRunning {
  return !!_manager;
}

@end

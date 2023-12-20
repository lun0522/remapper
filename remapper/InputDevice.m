//
//  InputDevice.m
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#import "InputDevice.h"

@implementation InputDevice {
  NSString* _name;
  int _vendorId;
  int _productId;
}

- (id)initWithDevice:(IOHIDDeviceRef)device {
  if ((self = [super init])) {
    _name = (__bridge NSString*)IOHIDDeviceGetProperty(device,
                                                       CFSTR(kIOHIDProductKey));
    _vendorId = [(__bridge NSNumber*)IOHIDDeviceGetProperty(
        device, CFSTR(kIOHIDVendorIDKey)) intValue];
    _productId = [(__bridge NSNumber*)IOHIDDeviceGetProperty(
        device, CFSTR(kIOHIDProductIDKey)) intValue];
  }
  return self;
}

- (NSString*)uid {
  return [NSString stringWithFormat:@"%@:%d:%d", _name, _vendorId, _productId];
}

@end

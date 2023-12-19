//
//  main.m
//  remapper
//
//  Created by Pujun Lun on 12/19/23.
//

#import <Cocoa/Cocoa.h>

#import "ApplicationDelegate.h"

int main(int argc, const char* argv[]) {
  [NSApplication sharedApplication];
  [NSApp setDelegate:(id<NSApplicationDelegate>)[ApplicationDelegate new]];
  return NSApplicationMain(argc, argv);
}

#import "virtualization_vnc.h"
#import "virtualization_helper.h"
#import <Foundation/Foundation.h>
#import <Virtualization/Virtualization.h>

@interface _VZVNCSecurityConfiguration : NSObject <NSCopying>
@end

@interface _VZVNCNoSecuritySecurityConfiguration : _VZVNCSecurityConfiguration
@end

@interface _VZVNCAuthenticationSecurityConfiguration : _VZVNCSecurityConfiguration
@property (readonly, copy) NSString *password;
    - (instancetype)initWithPassword : (NSString *)password;
@end

@protocol _VZFramebufferObserver <NSObject>
@end

@protocol _VZVNCServerDelegate;

@interface _VZVNCServer : NSObject <_VZFramebufferObserver>
@property long long state;
@property (weak) id<_VZVNCServerDelegate> delegate;
@property (readonly) dispatch_queue_t queue;
@property (readonly) short port;
@property (readonly, copy) _VZVNCSecurityConfiguration *securityConfiguration;
@property (retain) VZVirtualMachine *virtualMachine;

- (instancetype)initWithPort:(NSInteger)port
                       queue:(dispatch_queue_t)queue
       securityConfiguration:(_VZVNCSecurityConfiguration *)securityConfiguration;
- (void)start;
- (void)stop;
@end

void *newVZVNCServer(int port, void *vmQueue, const char *password)
{
    if (@available(macOS 12, *)) {
        _VZVNCSecurityConfiguration *securityConfiguration;
        if (password != NULL) {
            NSString *passwordNSString = [NSString stringWithUTF8String:password]; // not owned
            securityConfiguration = [[_VZVNCAuthenticationSecurityConfiguration alloc] initWithPassword:passwordNSString];
        } else {
            securityConfiguration = [[_VZVNCNoSecuritySecurityConfiguration alloc] init];
        }
        _VZVNCServer *server = [[_VZVNCServer alloc] initWithPort:(NSInteger)port queue:vmQueue securityConfiguration:securityConfiguration];
        [securityConfiguration release]; // the constructor retained or made a copy
        return server;
    }

    RAISE_UNSUPPORTED_MACOS_EXCEPTION();
}

void setVirtualMachineVZVNCServer(void *server, void *vm)
{
    if (@available(macOS 12, *)) {
        _VZVNCServer *serverObj = (_VZVNCServer *)server;
        VZVirtualMachine *vmObj = (VZVirtualMachine *)vm;
        serverObj.virtualMachine = vmObj;
        return;
    }

    RAISE_UNSUPPORTED_MACOS_EXCEPTION();
}

void startVZVNCServer(void *server)
{
    if (@available(macOS 12, *)) {
        _VZVNCServer *serverObj = (_VZVNCServer *)server;
        return [serverObj start];
    }

    RAISE_UNSUPPORTED_MACOS_EXCEPTION();
}

void stopVZVNCServer(void *server)
{
    if (@available(macOS 12, *)) {
        _VZVNCServer *serverObj = (_VZVNCServer *)server;
        return [serverObj stop];
    }

    RAISE_UNSUPPORTED_MACOS_EXCEPTION();
}
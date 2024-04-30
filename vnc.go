package vz

/*
#cgo darwin CFLAGS: -mmacosx-version-min=11 -x objective-c -fno-objc-arc
#cgo darwin LDFLAGS: -lobjc -framework Foundation -framework Virtualization
# include "virtualization_vnc.h"
*/
import "C"
import "github.com/Code-Hex/vz/v3/internal/objc"

// MacOSInstaller is a struct you use to install macOS on the specified virtual machine.
type VNCServer struct {
	*pointer
}

func NewVNCServer(vm *VirtualMachine, port int, password string) (*VNCServer, error) {
	if err := macOSAvailable(12); err != nil {
		return nil, err
	}

	var passwordChars *char
	if password != "" {
		passwordChars := charWithGoString(password)
		defer passwordChars.Free()
	}

	server := C.newVZVNCServer(C.int(port), vm.dispatchQueue, passwordChars.CString())
	C.setVirtualMachineVZVNCServer(server, objc.Ptr(vm.pointer))

	ret := &VNCServer{
		pointer: objc.NewPointer(server),
	}
	objc.SetFinalizer(ret, func(self *VNCServer) {
		objc.Release(self.pointer)
	})
	return ret, nil
}

func (vnc *VNCServer) Start() {
	C.startVZVNCServer(objc.Ptr(vnc.pointer))
}

func (vnc *VNCServer) Stop() {
	C.stopVZVNCServer(objc.Ptr(vnc.pointer))
}

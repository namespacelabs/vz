#pragma once

void *newVZVNCServer(int port, void *vmQueue, const char *password);
void setVirtualMachineVZVNCServer(void *server, void *vm);
void startVZVNCServer(void *server);
void stopVZVNCServer(void *server);
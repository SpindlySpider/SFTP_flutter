#ifndef MY_KNOWN_HOST_H
#define MY_KNOWN_HOST_H
#include <libssh/libssh.h>

int verify_knownhost(ssh_session session);

#endif
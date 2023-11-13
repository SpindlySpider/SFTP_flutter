#ifndef MY_KNOWN_HOST_H
#define MY_KNOWN_HOST_H
#include <libssh/libssh.h>

int verify_knownhost(ssh_session session,char* error_message);
int SSH_KNOWN_HOSTS_UNKOWN_handle(ssh_session ssh_sesh,char* error_message);
#endif
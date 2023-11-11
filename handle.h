#include <libssh/libssh.h>
#ifdef __cplusplus
extern "C" {
#endif

char* print_ssh_error(ssh_session ssh_sesh);
ssh_session init_ssh();
void ssh_set_connection_info(ssh_session ssh_sesh,char* hostname, int port);
char* try_ssh_connect_server(ssh_session ssh_sesh);
int verify_host(ssh_session ssh_sesh);
char* try_password_authentication(ssh_session ssh_sesh,char* password);
void my_ssh_disconnect(ssh_session ssh_sesh);
void my_ssh_free(ssh_session ssh_sesh);
void deallocate_str(char* string_ptr);

#ifdef __cplusplus
}
#endif
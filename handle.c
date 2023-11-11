#include <libssh/libssh.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "my_known_host.h"
 
//order to use this ssh handle is
//init_ssh -> ssh_set_connection_info -> char* try_ssh_connect_server ->verify_host -> try_password_authentication -> do what you need to do

//exiting ssh_disconnect(if active session) -> ssh_free

// if main sftp ever returns -1 then use the print_ssh_connection_error

char* print_ssh_error(ssh_session ssh_sesh){
  const char* error_message = ssh_get_error(ssh_sesh);
  return (char*)error_message;

  // printf(error_message);
  // strcat(str1,(char*)error_message);
}


ssh_session init_ssh(){
  ssh_session my_ssh_session = ssh_new();
  return my_ssh_session;
}
void ssh_set_connection_info(ssh_session ssh_sesh,char* hostname, int port){
  // might cause error because its references in the memory address
  ssh_options_set(ssh_sesh, SSH_OPTIONS_HOST, hostname);
  ssh_options_set(ssh_sesh, SSH_OPTIONS_PORT, &port);
}

char* try_ssh_connect_server(ssh_session ssh_sesh){
  int rc;
  printf("ssh_1");
  rc = ssh_connect(ssh_sesh);
  if(rc != SSH_OK){
    printf(print_ssh_error(ssh_sesh));
    return print_ssh_error(ssh_sesh);
  }
  // if everything is okay it will return a empty string
  return "connect successful";
}

int verify_host(ssh_session ssh_sesh){
  int host;
  printf("verifying host\n");
  host = verify_knownhost(ssh_sesh);
  printf("verifying host\n");
  printf("%d\n",host); 
 if (host < 0)
  {
    ssh_disconnect(ssh_sesh);
    ssh_free(ssh_sesh);
    exit(-1);
  }
}

char* try_password_authentication(ssh_session ssh_sesh,char* password){
  int rc;
  rc = ssh_userauth_password(ssh_sesh, NULL, password);
  if (rc != SSH_AUTH_SUCCESS)
  {
    char* error_message;
    error_message = print_ssh_error(ssh_sesh);
    ssh_disconnect(ssh_sesh);
    ssh_free(ssh_sesh);
    return error_message;
  }
  return "password pass";
}


int main_sftp(ssh_session _ssh_session)
{
    // needs to grab host name and ssh session, password, port
  ssh_session my_ssh_session;
  int rc;
  char *password;
 
  // Open session and set options
  if (_ssh_session == NULL)
    exit(-1);
  ssh_set_connection_info(_ssh_session,"192.168.1.1",22);
  try_ssh_connect_server(_ssh_session); // will return string
  verify_host(_ssh_session); // returns int

 
  // Connect to server
  /*
  rc = ssh_connect(_ssh_session);
  if (rc != SSH_OK)
  {
    
    !IMPORTANT THIS AREA IS USED IN THE PRINT SSH THING, NEED TO MANUALLY RELEASE THE SSH SESSION
    fprintf(stderr, "Error connecting to localhost: %s\n",
            ssh_get_error(_ssh_session));
    ssh_free(_ssh_session);
  
   // could use like -2 to show that it is a connect error? and handle specifically
    exit(-1);
  }
  */

  // Verify the server's identity
  // For the source code of verify_knownhost(), check previous example
  /*
  if (verify_knownhost(_ssh_session) < 0)
  {
    ssh_disconnect(_ssh_session);
    ssh_free(_ssh_session);
    exit(-1);
  }
 */

  /*
  // Authenticate ourselves
  password = getpass("Password: ");
  rc = ssh_userauth_password(_ssh_session, NULL, password);
  if (rc != SSH_AUTH_SUCCESS)
  {
    fprintf(stderr, "Error authenticating with password: %s\n",
            ssh_get_error(_ssh_session));
    ssh_disconnect(_ssh_session);
    ssh_free(_ssh_session);
    exit(-1);
  }
*/

 
  ssh_disconnect(_ssh_session);
  ssh_free(_ssh_session);
}



void my_ssh_disconnect(ssh_session ssh_sesh){
  ssh_disconnect(ssh_sesh);
}
void my_ssh_free(ssh_session ssh_sesh){
  ssh_free(ssh_sesh);

}

void deallocate_str(char* string_ptr){
  free(string_ptr);
}

int main(){
  ssh_session ssh_sesh = init_ssh();
  ssh_set_connection_info(ssh_sesh,"35.195.25.151",22);
  if (ssh_sesh == NULL){

    exit(-1);
  }
  char* error_message;
  error_message = try_ssh_connect_server(ssh_sesh); 
  printf(error_message);
  verify_host(ssh_sesh);
  error_message = try_password_authentication(ssh_sesh,"RjHRL4v8"); 
  printf(error_message);
  printf("finsihied\n");
  my_ssh_disconnect(ssh_sesh);
  my_ssh_free(ssh_sesh);
  return 0;
}
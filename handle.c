#include <libssh/libssh.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "my_known_host.h"
#define LIBSSH_STATIC 1
 
//order to use this ssh handle is
//init_ssh -> ssh_set_connection_info -> char* try_ssh_connect_server ->verify_host -> try_password_authentication -> do what you need to do

//exiting ssh_disconnect(if active session) -> ssh_free

// if main sftp ever returns -1 then use the print_ssh_connection_error

int ssh_exit(ssh_session ssh_sesh){
    ssh_disconnect(ssh_sesh);
    ssh_free(ssh_sesh);
    ssh_finalize();
    exit(-1);
}

char* print_ssh_error(ssh_session ssh_sesh){
  const char* error_message = ssh_get_error(ssh_sesh);
  return (char*)error_message;

  // printf(error_message);
  // strcat(str1,(char*)error_message);
}



void ssh_set_connection_info(ssh_session ssh_sesh,char* hostname, int port){
  // might cause error because its references in the memory address
  ssh_options_set(ssh_sesh, SSH_OPTIONS_HOST, hostname);
  ssh_options_set(ssh_sesh, SSH_OPTIONS_PORT, &port);
}

void try_ssh_connect_server(ssh_session ssh_sesh,char* error_message){
  strcpy(error_message, "SOMTHING");
  int rc;
  rc = ssh_connect(ssh_sesh);
  if(rc == SSH_ERROR){
    rc =  ssh_get_error_code(ssh_sesh);
    if(rc == SSH_REQUEST_DENIED){
     strcpy(error_message, "ssh request denied");
    }
    else if(rc == SSH_FATAL){
     strcpy(error_message, "ssh fatal");
    }
    else{
      strcpy(error_message, "other");
    }
  }
  else if (rc==SSH_OK){
    strcpy(error_message,"connect successful");
  // if everything is okay it will return a empty string
  }
  else{
    strcpy(error_message,"other error");
  }

  
}

int verify_host(ssh_session ssh_sesh,char* error_message){
  int host;
  host = verify_knownhost(ssh_sesh,error_message);
  printf("verifying host\n");
  printf("%d\n",host);
  if (host == -2){
    return host;
  } 
  else if (host < 0)
  {
    //exit 
    return host;
  }
  return 0;
}



 void try_password_authentication(ssh_session ssh_sesh,char* password,char* error_message){
  int rc;
  rc = ssh_userauth_password(ssh_sesh, NULL, password);
  if (rc != SSH_AUTH_SUCCESS)
  {
    error_message = print_ssh_error(ssh_sesh);
    ssh_disconnect(ssh_sesh);
    ssh_free(ssh_sesh);
  }
  error_message = "";
}


// int main_sftp(ssh_session _ssh_session)
// {
//     // needs to grab host name and ssh session, password, port
//   ssh_session my_ssh_session;
//   int rc;
//   char *password;
 
//   // Open session and set options
//   if (_ssh_session == NULL)
//     exit(-1);
//   ssh_set_connection_info(_ssh_session,"192.168.1.1",22);
//   try_ssh_connect_server(_ssh_session); // will return string
//   verify_host(_ssh_session); // returns int
 
//   ssh_disconnect(_ssh_session);
//   ssh_free(_ssh_session);
// }



void my_ssh_disconnect(ssh_session ssh_sesh){
  ssh_disconnect(ssh_sesh);
}
void my_ssh_free(ssh_session ssh_sesh){
  ssh_free(ssh_sesh);
}
void my_ssh_finalize(){
  ssh_finalize();
}
void deallocate_str(char* string_ptr){
  free(string_ptr);
}


ssh_session init_ssh(){
  ssh_init();
  return ssh_new();
  
}

int main(){
  int host;
  ssh_init();
  //ssh_session ssh_sesh=init_ssh();
  ssh_session ssh_sesh = ssh_new();
  int port =22;
  char* hostname = "104.199.4.219";
  ssh_set_connection_info(ssh_sesh,hostname,port);
  if (ssh_sesh == NULL){

    exit(-1);
  }
  char* error_message = (char*)malloc(250);
  try_ssh_connect_server(ssh_sesh,error_message); 
  printf(error_message);
  memset(error_message,0,sizeof(error_message));
  error_message[0] = '\0';
  host = verify_host(ssh_sesh,error_message);
  if (host<0){
    if (host==-2){
      //add the code for yes or no here, use a pop up :)
      SSH_KNOWN_HOSTS_UNKOWN_handle(ssh_sesh,error_message);
      printf("%s \n",error_message);

    }
    else{
      printf("%s \n",error_message);
      //ssh_exit(ssh_sesh);
    }
  }
  else{
  try_password_authentication(ssh_sesh,"RjHRL4v8",error_message); 

  }
  printf(error_message);
  ssh_disconnect(ssh_sesh);
  printf("finsihied\n");
  printf("2\n");
  ssh_free(ssh_sesh);
  ssh_finalize();
  printf("3\n");
  fprintf( stdout, "hello world\n" );
  printf("fsdfdsfsd");
  // free(error_message);
  printf("4\n");
  return 0;
}



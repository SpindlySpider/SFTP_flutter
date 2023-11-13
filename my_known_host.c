#include <libssh/libssh.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "my_known_host.h"

int verify_knownhost(ssh_session session,char* error_message){
    // this function will return a integer, need to use helper function to diagnose error message
    //used for ffi so you can actually tell what the error is.
    enum ssh_known_hosts_e state;
    unsigned char *hash = NULL;
    ssh_key srv_pubkey = NULL;
    size_t hlen;
    char buf[10];
    char *hexa;
    char *p;
    int cmp;
    int rc;
    char* temp_error_string = "";

    rc = ssh_get_server_publickey(session, &srv_pubkey);
    if(rc <0){
        return -1;
    }
    rc = ssh_get_publickey_hash(srv_pubkey,
                                SSH_PUBLICKEY_HASH_SHA256,
                                &hash,
                                &hlen);
    ssh_key_free(srv_pubkey);
    if (rc < 0) {
        return -1;
    }
    state = ssh_session_is_known_server(session);
    switch (state) {
        case SSH_KNOWN_HOSTS_OK:
            /* OK */
            break;
        case SSH_KNOWN_HOSTS_CHANGED:
            strcat(temp_error_string,"Host key for server changed: it is now:\n");
            strcat(temp_error_string,"SSH_PUBLICKEY_HASH_SHA256 : ");
            strcat(temp_error_string,ssh_get_hexa(hash,hlen));
            strcat(temp_error_string,"\n For security reasons, connection will be stopped\n");
            error_message = temp_error_string;
            ssh_clean_pubkey_hash(&hash);

            return -1;
        case SSH_KNOWN_HOSTS_OTHER:
            strcat(temp_error_string,"The host key for this server was not found but an other"
                    "type of key exists.\n");
            strcat(temp_error_string,"An attacker might change the default server key to"
                    "confuse your client into thinking the key does not exist\n");
            ssh_clean_pubkey_hash(&hash);
            error_message = temp_error_string;
 
            return -1;
        case SSH_KNOWN_HOSTS_NOT_FOUND:
            strcat(temp_error_string,"Could not find known host file.\n If you accept the host key here, the file will be automatically created.\n");
            error_message = temp_error_string;
            /* FALL THROUGH to SSH_SERVER_NOT_KNOWN behavior */
 
        case SSH_KNOWN_HOSTS_UNKNOWN:
        // type yes here and it will work
            hexa = ssh_get_hexa(hash, hlen);
            fprintf(stderr,"The server is unknown. Do you trust the host key?\n");
            fprintf(stderr, "Public key hash: %s\n", hexa);

            ssh_string_free_char(hexa);
            ssh_clean_pubkey_hash(&hash);
            //return with a differnt number and handle yes or no from client by passing in function 
            //IMPORTANT USES A DIFFERNT FUNCTION TO FINISH THE HANDLING OF THIS
            //uses -2 to show that it is the SSH_KNOWN_HOSTS_UNKOWN
            //have seprate functions for yes or no in this condition and call those.
            //could have a always trust option  in the mysql database

            return -2;
 
            break;
        case SSH_KNOWN_HOSTS_ERROR:
            fprintf(stderr, "Error %s", ssh_get_error(session));
            ssh_clean_pubkey_hash(&hash);
            return -1;
    }
 
    ssh_clean_pubkey_hash(&hash);
    error_message = "ok";
    return 0;
}



int SSH_KNOWN_HOSTS_UNKOWN_handle(ssh_session ssh_sesh,char* error_message){
    // if yes call this other wise break ssh sesh
    unsigned char *hash = NULL;
    ssh_key srv_pubkey = NULL;
    size_t hlen;
    char *hexa;
    int rc;
    char* error_str_temp = "";
    rc = ssh_session_update_known_hosts(ssh_sesh);
        if (rc < 0) {
            strcat(error_str_temp, strerror(errno));
            error_message = error_str_temp;
            return -1;
        }
    ssh_clean_pubkey_hash(&hash);
    error_message = "ok";
    return 0;
}

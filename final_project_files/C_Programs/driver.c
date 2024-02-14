/*
 * This is a complete C program that can be compiled with gcc and executable 
 * on Linux and MacOS.
 */

#include <string.h> // bzero, strncpy
#include <stdlib.h>  // malloc, free
#include <signal.h>  // signal
#include <unistd.h>  // alarm
#include <stdio.h>   // printf

int* alarmed;

void sig_handler1( int signum ) {
	*alarmed = 2;
}

void sig_handler2( int signum ) {
	*alarmed = 3;
}

int main( ) {
  char stringA[40] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabc\0";
  char stringB[40];
  
  bzero( stringB, 40 );
  strncpy( stringB, stringA, 40 );
  bzero( stringA, 40 );
  printf( "%s\n", stringA );
  printf( "%s\n", stringB );
  
  void* mem1 = malloc( 1024 );
  void* mem2 = malloc( 1024 );
  void* mem3 = malloc( 8192 );
  void* mem4 = malloc( 4096 );
  void* mem5 = malloc( 512 );
  void* mem6 = malloc( 1024 );
  void* mem7 = malloc( 512 );
  
  free( mem6 );
  free( mem5 );
  free( mem1 );
  free( mem7 );
  free( mem2 );
  
  void* mem8 = malloc( 4096 );
  
  free( mem4 );
  free( mem3 );
  free( mem8 );
  
  alarmed = (int *)malloc( 4 );
  *alarmed = 1;
  printf( "%d\n", *alarmed);
  
  signal( SIGALRM, sig_handler1 );
  alarm( 2 );
  while ( *alarmed != 2 ) {
    void* mem9 = malloc( 4 );	
    free( mem9 );		
  }
  printf( "%d\n", *alarmed);
  
  signal( SIGALRM, sig_handler2 );
  alarm( 3 );
  while ( *alarmed != 3 ) {
    void* mem9 = malloc( 4 );	
    free( mem9 );
  }
  printf( "%d\n", *alarmed);
  
  return 0;
}

/*
 * This is a C program that should be used to test your heap.c toward your 
 * midpoint report.
 *
 * malloc( ): renamed _malloc( )
 * free( ):   renamed  _free( )
 * printf( ): included
 * alarm( ):  commented out
 * signal( ): commented out
 */

#include <string.h> // bzero, strncpy
#include <stdlib.h>  // malloc, free
#include <signal.h>  // signal
#include <unistd.h>  // alarm
#include <stdio.h>   // printf

extern void *_malloc( int size );  // you need to implement in heap.c
extern void *_free( void *ptr );   // you need to implement in heap.c

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
  
  void* mem1 = _malloc( 1024 );
  printf( "mem1 = %x\n", mem1 );

  void* mem2 = _malloc( 1024 );
  printf( "mem2 = %x\n", mem2 );

  void* mem3 = _malloc( 8192 );
  printf( "mem3 = %x\n", mem3 );
  
  void* mem4 = _malloc( 4096 );
  printf( "mem4 = %x\n", mem4 );
  
  void* mem5 = _malloc( 512 );
  printf( "mem5 = %x\n", mem5 );
  
  void* mem6 = _malloc( 1024 );
  printf( "mem6 = %x\n", mem6 );
  
  void* mem7 = _malloc( 512 );
  printf( "mem7 = %x\n", mem7 );

  _free( mem6 );
  _free( mem5 );
  _free( mem1 );
  _free( mem7 );
  _free( mem2 );
  
  void* mem8 = _malloc( 4096 );
  printf( "mem8 = %x\n", mem8 );
  
  _free( mem4 );
  _free( mem3 );
  _free( mem8 );

  /*
  alarmed = (int *)_malloc( 4 );
  *alarmed = 1;
  printf( "%d\n", *alarmed);
  
  signal( SIGALRM, sig_handler1 );
  alarm( 2 );
  while ( *alarmed != 2 ) {
    void* mem9 = _malloc( 4 );	
    _free( mem9 );		
  }
  printf( "%d\n", *alarmed);
  
  signal( SIGALRM, sig_handler2 );
  alarm( 3 );
  while ( *alarmed != 3 ) {
    void* mem9 = _malloc( 4 );	
    _free( mem9 );
  }
  printf( "%d\n", *alarmed);
  */
  
  return 0;
}

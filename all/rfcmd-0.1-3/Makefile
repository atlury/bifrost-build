CC=gcc
CFLAGS= -Os -Wall -march=i586
LDFLAGS=-static
rfcmd:	rfcmd.o
	$(CC) $(LDFLAGS) -o rfcmd rfcmd.o -ldevtag
clean:
	rm -f *.o rfcmd

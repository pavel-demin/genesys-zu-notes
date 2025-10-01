/*
compilation command:
gcc -O3 -D_GNU_SOURCE test.c -o test
*/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define ADDR "10.1.1.112"
#define PORT 1234

#define N 1048576UL

int main()
{
  int result, sock, value;
  struct sockaddr_in addr;
  struct iovec *iovec;
  struct mmsghdr *datagram;
  struct timespec ts;
  uint64_t i, *data, command[4];

  iovec = malloc(sizeof(struct iovec) * N);
  datagram = malloc(sizeof(struct mmsghdr) * N);
  data = malloc(8192 * N);

  if(data == NULL)
  {
    perror("malloc");
    return EXIT_FAILURE;
  }

  memset(iovec, 0, sizeof(struct iovec) * N);
  memset(datagram, 0, sizeof(struct mmsghdr) * N);

  for(i = 0; i < N; ++i)
  {
    iovec[i].iov_base = data + 1024 * i;
    iovec[i].iov_len = 8192;
    datagram[i].msg_hdr.msg_iov = &iovec[i];
    datagram[i].msg_hdr.msg_iovlen = 1;
  }

  if((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
  {
    perror("socket");
    return EXIT_FAILURE;
  }

  value = 1;
  if(setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &value, sizeof(value)))
  {
    perror("setsockopt");
    return EXIT_FAILURE;
  }

  value = 1073741824;
  if(setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &value, sizeof(value)))
  {
    perror("setsockopt");
    return EXIT_FAILURE;
  }

  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(PORT);

  if(bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0)
  {
    perror("bind");
    return EXIT_FAILURE;
  }

  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = inet_addr(ADDR);
  addr.sin_port = htons(PORT);

  printf("start\n");

  command[0] = (1UL << 63) + 0;
  command[1] = 0;
  command[2] = (1UL << 63) + 0;
  command[3] = 1;

  sendto(sock, command, 32, 0, (struct sockaddr *)&addr, sizeof(addr));

  for(i = 0; i < 16; ++i)
  {
    ts.tv_sec = 10;
    ts.tv_nsec = 0;

    result = recvmmsg(sock, datagram, N, 0, &ts);

    printf("result: %d\n", result);
    printf("%ld %ld %ld\n", data[0], data[1024 * N - 1], data[1024 * N - 1] - data[0]);
  }

  printf("stop\n");

  sendto(sock, command, 16, 0, (struct sockaddr *)&addr, sizeof(addr));

  return EXIT_SUCCESS;
}

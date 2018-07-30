#ifndef BASE64_H
#define BASE64_H

uint8_t *decode64(uint8_t *dst, uint8_t *src, size_t *len, bool pad);
uint8_t *encode64(uint8_t *dst, uint8_t *src, size_t *len, bool pad);
uint8_t *decode64url(uint8_t *dst, uint8_t *src, size_t *len, bool pad);
uint8_t *encode64url(uint8_t *dst, uint8_t *src, size_t *len, bool pad);

#endif /* BASE64_H */

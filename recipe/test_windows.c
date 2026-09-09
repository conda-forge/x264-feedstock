/* Verify installed Windows architecture and eight-frame Annex B encoding. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void require(int condition, const char *message)
{
    if (!condition) {
        fprintf(stderr, "%s\n", message);
        exit(1);
    }
}

static unsigned char *read_file(const char *path, long *size)
{
    FILE *file = fopen(path, "rb");
    require(file != NULL, path);
    require(fseek(file, 0, SEEK_END) == 0, "seek failed");
    *size = ftell(file);
    require(*size > 0, "empty file");
    rewind(file);
    unsigned char *data = malloc((size_t)*size);
    require(data != NULL, "allocation failed");
    require(fread(data, 1, (size_t)*size, file) == (size_t)*size, "read failed");
    fclose(file);
    return data;
}

static void check_pe(const char *path)
{
    long size;
    unsigned char *data = read_file(path, &size);
    require(size > 0x40, "missing DOS header");
    unsigned long pe = data[0x3c] | ((unsigned long)data[0x3d] << 8) |
        ((unsigned long)data[0x3e] << 16) | ((unsigned long)data[0x3f] << 24);
    require(pe + 6 <= (unsigned long)size, "missing PE header");
    require(memcmp(data + pe, "PE\0\0", 4) == 0, "invalid PE signature");
    unsigned machine = data[pe + 4] | ((unsigned)data[pe + 5] << 8);
#ifdef _M_ARM64
    require(machine == 0xaa64, "expected ARM64 binary");
#else
    require(machine == 0x8664, "expected x64 binary");
#endif
    printf("PE 0x%04x: %s\n", machine, path);
    free(data);
}

static void check_video(const char *path)
{
    long size;
    unsigned char *data = read_file(path, &size);
    unsigned headers = 0, frames = 0;
    for (long i = 0; i + 3 < size; ++i) {
        if (data[i] == 0 && data[i + 1] == 0 && data[i + 2] == 1) {
            unsigned type = data[i + 3] & 31;
            if (type == 5) headers |= 1;
            if (type == 7) headers |= 2;
            if (type == 8) headers |= 4;
            if (type == 1 || type == 5) ++frames;
        }
    }
    require(headers == 7 && frames == 8, "expected eight frames and SPS/PPS/IDR NAL units");
    printf("%s: eight encoded frames, SPS/PPS/IDR verified (%ld bytes)\n", path, size);
    free(data);
}

int main(int argc, char **argv)
{
    require(argc >= 3, "usage: test-windows prepare|verify files...");
    if (strcmp(argv[1], "prepare") == 0) {
        for (int i = 2; i < argc; ++i) check_pe(argv[i]);
        FILE *file = fopen("input.yuv", "wb");
        require(file != NULL, "cannot create input");
        for (int frame = 0; frame < 8; ++frame)
            for (int pixel = 0; pixel < 32 * 32 * 3 / 2; ++pixel)
                require(fputc(pixel < 32 * 32 ? (pixel + frame * 8) % 256 : 128, file) != EOF, "write failed");
        require(fclose(file) == 0, "close failed");
    } else {
        require(strcmp(argv[1], "verify") == 0, "unknown operation");
        for (int i = 2; i < argc; ++i) check_video(argv[i]);
    }
    return 0;
}

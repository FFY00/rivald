module rivald.values;

/**
 * Buffer sizes
 */
enum Size : ushort
{
    NORMAL = 64,
    LONG = 262
}

/**
 * Dpi
 */
enum Dpi : ushort
{
    STEP = 100,
    MAX = 12_000
}

/**
 * Rate
 */
enum Rate : ushort
{
    MIN = 125,
    MAX = 1000
}

/**
 * Led ID
 */
enum Led : ubyte
{
    LOGO = 0,
    WHEEL
}

/**
 * Mouse commands
 *
 * https://github.com/FFY00/rival310-re
 */
enum Command : ubyte
{
    RESET           = 0x01,
    RESET_LED       = 0x40,
    DPI             = 0x53,
    RATE            = 0x54,
    SAVE            = 0x59,
    DPI_UNKNOWN     = 0x5A,
    LED             = 0x5B,
    FIRMWARE        = 0x90,
    READ_DPI        = 0x92,
    BUTON_REPORT    = 0xFF
}
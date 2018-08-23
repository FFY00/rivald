module rivald.device;

// 
// Rivald
// 
import rivald.cycle;
import rivald.error;
import rivald.values;

// 
// Hidapi-d
// 
import hidapi.device;
import hidapi.devicelist;

// 
// Std
// 
import std.exception : enforce;
import std.experimental.logger;
import std.format : format;
import std.math : log2;
import std.typecons : Tuple, tuple;

// 
// Core
// 
import core.thread;

class RivalDevice
{
    private Device dev;

    /**
     * Destructor
     */
    ~this()
    {
        destroy(dev); // make sure we destroy dev to properly close hidapi
    }

    /**
     * Opens the first matching device
     */
    this()
    {
        dev = new Device(0x1038, 0x1720);
    }

    /**
     * Opens the first matching device
     *
     * Params:
     *      serial_nuber =  Serial Number
     */
    this(string serial_number)
    {
        dev = new Device(0x1038, 0x1720, serial_number);
    }

    /**
     * Opens the first matching device
     *
     * Params:
     *      vendor_id =     Vendor ID
     *      product_id =    Product ID
     */
    this(uint vendor_id, uint product_id)
    {
        warning("Unsafe function: You are directly opening a device.\nThis library (rivald) was meant " ~
                "to be used with the Steelseries Rival 310. Use this function at your own risk!");
        dev = new Device(vendor_id, product_id);
    }

    /**
     * Opens the first matching device
     *
     * Params:
     *      vendor_id =     Vendor ID
     *      product_id =    Product ID
     *      serial_nuber =  Serial Number
     */
    this(uint vendor_id, uint product_id, string serial_number)
    {
        warning("Unsafe function: You are directly opening a device.\nThis library (rivald) was meant " ~
                "to be used with the Steelseries Rival 310. Use this function at your own risk!");
        dev = new Device(vendor_id, product_id, serial_number);
    }

    /**
     * Opens a specific device
     *
     * Params:
     *      serial_nuber =  Serial Number
     */
    /*
    this(string path)
    {
        warning("Unsafe function: You are directly opening a device.\nThis library (rivald) was meant " ~
                "to be used with the Steelseries Rival 310. Use this function at your own risk!");
        dev = new Device(path);
    }
    */

    /**
     * Opens a specific device
     *
     * Params:
     *      serial_nuber =  Serial Number
     */
    this(Device dev)
    {
        warning("Unsafe function: You are directly opening a device.\nThis library (rivald) was meant " ~
                "to be used with the Steelseries Rival 310. Use this function at your own risk!");
        this.dev = dev;
    }

    /**
     * Change DPI 
     *
     * Params:
     *      id =    DPI ID (1 or 2)
     *      value = DPI value
     *
     * https://github.com/FFY00/rival310-re/blob/master/53.md
     * https://github.com/FFY00/rival310-re/blob/master/5A.md
     */
    void setDpi(ubyte id, uint value)
    {
        enforce!RivalError(id == 1 || id == 2, "Invalid DPI ID.");
        enforce!RivalError(value >= Dpi.STEP && value <= Dpi.MAX, 
                            format!"Invalid DPI value (min. %d, max. %d)."(Dpi.STEP, Dpi.MAX));

        auto steps = (value - Dpi.STEP) / Dpi.STEP;
        auto rem = (value - Dpi.STEP) % Dpi.STEP;

        // Round .5 and up
        if(rem >= Dpi.STEP / 2)
                steps++;
        
        warning(rem != 0,
                format!"Invalid DPI value, asserting from %d to %d"(value, steps * Dpi.STEP + Dpi.STEP));

        // Write DPI values (53)
        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = Command.DPI;
        buf[2] = id;
        buf[3] = cast(ubyte) steps;

        log(buf);

        assert(steps >= 0 && steps <= 119 );

        dev.write(buf, Size.NORMAL);
        Thread.sleep(10.msecs);

        // Save DPI values? (5A)
        buf = new ubyte[Size.NORMAL];
        buf[0] = Command.DPI_UNKNOWN;
        buf[2] = cast(ubyte) (id - 1);

        log(buf);

        dev.write(buf, Size.NORMAL);
        Thread.sleep(10.msecs);
    }

    /**
     * Reads DPI values
     *
     * Warning! Can return an empty array.
     * https://github.com/FFY00/rival310-re/blob/master/92.md
     */
    Tuple!(ushort, ushort) readDpi()
    {
        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = Command.READ_DPI;

        auto res = dev.command(buf, Size.NORMAL);
        Thread.sleep(10.msecs);

        log(res);

        return tuple(   cast(ushort) (Dpi.STEP * res[2] + Dpi.STEP),
                        cast(ushort) (Dpi.STEP * res[4] + Dpi.STEP));
    }

    /**
     * Reads DPI value
     *
     * Params:
     *      id =    DPI ID (1 or 2)
     *
     * Warning! Can return -1.
     * https://github.com/FFY00/rival310-re/blob/master/92.md
     */
    ushort readDpi(ubyte id)
    {
        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = Command.READ_DPI;

        auto res = dev.command(buf, Size.NORMAL);
        Thread.sleep(10.msecs);

        if(id == 1)
            return Dpi.STEP * res[2] + Dpi.STEP;

        if(id == 2)
            return Dpi.STEP * res[4] + Dpi.STEP;

        return 0;
    }

    /**
     * Change report rate 
     *
     * Params:
     *      value = rate value
     *
     * https://github.com/FFY00/rival310-re/blob/master/54.md
     */
    void setRate(uint value)
    {
        enforce!RivalError(value >= Rate.MIN && value <= Rate.MAX,
                            format!"Invalid Report Rate value (min. %d, max. %d)."(Rate.MIN, Rate.MAX));

        auto calc(T)(T steps)
        {
            return Rate.MAX / (2 ^^ (steps - 1));
        }

        ubyte round(real steps)
        {
            ubyte steps_int = cast(ubyte) steps;
            uint step_val = cast(uint) (calc(steps_int) - calc(steps + 1));

            if(calc(steps_int) - value > step_val / 2)
                steps_int++;

            return steps_int;
        }

        const ubyte steps = round(log2(2 * Rate.MAX / value));
        
        warning(value != calc(steps),
                format!"Invalid Report Rate value, asserting from %d to %d"(value, calc(steps)));

        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = Command.RATE;
        buf[2] = steps;

        assert(steps >= 1 && steps <= 4 );

        dev.write(buf, Size.NORMAL);
        Thread.sleep(10.msecs);
    }

    /**
     * Save settings in the mouse
     *
     * https://github.com/FFY00/rival310-re/blob/master/59.md
     */
    void save()
    {
        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = Command.SAVE;

        dev.write(buf, Size.NORMAL);
        Thread.sleep(10.msecs);
    }

    /**
     * Set Led cycle
     *
     * Params:
     *      led =   Led ID
     *      cycle = Cycle to write
     *
     * https://github.com/FFY00/rival310-re/blob/master/5B.md
     */
    void setLedCycle(ubyte led, Cycle cycle)
    {
        enforce!RivalError(led == Led.LOGO || led == Led.WHEEL, "Invalid Led ID.");

        ubyte[Size.LONG] buf = cycle.getBuffer();

        dev.write(buf, Size.LONG);
        Thread.sleep(10.msecs);
    }

    /**
     * Set Led cycle
     *
     * Params:
     *      led =   Led ID
     *      points =    Points of the cycle
     *
     * https://github.com/FFY00/rival310-re/blob/master/5B.md
     */
    void setLedCycle(ubyte led, Point[] points)
    {
        enforce!RivalError(led == Led.LOGO || led == Led.WHEEL, "Invalid Led ID.");

        auto cycle = new Cycle(led);
        cycle.setPoints(points);

        ubyte[Size.LONG] buf = cycle.getBuffer();

        dev.write(buf, Size.LONG);
        Thread.sleep(10.msecs);
    }

    /**
     * Set Led cycle
     *
     * Params:
     *      led =   Led ID
     *      points =    Points of the cycle
     *      duration =  Duration of the cycle
     *
     * https://github.com/FFY00/rival310-re/blob/master/5B.md
     */
    void setLedCycle(ubyte led, Point[] points, ushort duration)
    {
        enforce!RivalError(led == Led.LOGO || led == Led.WHEEL, "Invalid Led ID.");

        auto cycle = new Cycle(led);
        cycle.setPoints(points);
        cycle.setDuration(duration);

        ubyte[Size.LONG] buf = cycle.getBuffer();

        dev.write(buf, Size.LONG);
        Thread.sleep(10.msecs);
    }

    /**
     * Reset LEDs
     *
     * https://github.com/FFY00/rival310-re
     */
    void resetLed()
    {
        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = Command.RESET_LED;

        dev.write(buf, Size.NORMAL);
        Thread.sleep(10.msecs);
    }

    /**
     * Reads firmware version
     *
     * https://github.com/FFY00/rival310-re/blob/master/90.md
     */
    Tuple!(ubyte, ubyte) readFirmware()
    {
        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = Command.FIRMWARE;

        auto res = dev.command(buf, Size.NORMAL);
        Thread.sleep(10.msecs);

        log(res);

        assert(res[1] == 1);

        return tuple(res[1], res[0]);
    }

    void test()
    {
        ubyte[] buf = new ubyte[Size.NORMAL];
        buf[0] = 0x91;
        buf[1] = 0;
        buf[2] = 2;
        buf[3] = 0;
        buf[4] = 0;

        //      9A - 2
        // 0 - 66
        // 1 - 1
        // 2 - 32

        auto res = dev.command(buf, Size.NORMAL);
        Thread.sleep(10.msecs);

        log(res);
    }

}
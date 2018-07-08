module rivald.cycle;

// 
// Rivald
// 
import rivald.error;
import rivald.util;
import rivald.values;

// 
// Std
// 
import std.bitmanip : nativeToLittleEndian;
import std.exception : enforce;

/// Point representation
struct Point
{
    // color
    ubyte red;
    ubyte green;
    ubyte blue;
    // relative position in the cycle
    ubyte pos;
}

/// Cycle representation
class Cycle
{
    private:
    ubyte led = Led.LOGO;
    ushort duration = 5000;
    bool repeat = true;
    ubyte trigger_buttons;
    Point[] points; 

    public:

    /**
     * Cycle constructor
     *
     * Params:
     *      led =   Led ID (0 or 1)
     */
    this(ubyte led)
    {
        enforce!RivalError(led == Led.LOGO || led == Led.WHEEL, "Invalid Led ID.");

        this.led = led;
    }

    /**
     *
     */
    void setPoints(Point[] points)
    {
        this.points = points;
    }

    /**
     * Contructs the buffer
     *
     * Returns: Contructed buffer
     *
     * https://github.com/FFY00/rival310-re/blob/master/5B.md
     */
    ubyte[Size.LONG] getBuffer()
    {
        ubyte[Size.LONG] buf;

        buf[0] = Command.LED;
        buf[2] = led;

        if(!repeat)
            buf[19] = 1;

        buf[27] = cast(ubyte) points.length;

        bool first_point;
        ubyte i;
        ushort cycle_size;
        CYCLE: foreach(point; points)
        {
            if(!first_point)
            {
                buf[28] = point.red;
                buf[29] = point.green;
                buf[30] = point.blue;
                first_point = true;
            }

            buf[31 + (i * 4)] = point.red;
            buf[32 + (i * 4)] = point.green;
            buf[33 + (i * 4)] = point.blue;
            buf[34 + (i * 4)] = point.pos;

            cycle_size += point.pos;

            if(cycle_size >= 255)
                break CYCLE;

            i++;
        }

        duration = cast(short) min_threshold(duration, buf[27] * 330);
        ubyte[2] dur = nativeToLittleEndian(duration);
        buf[3] = dur[0];
        buf[4] = dur[1];

        return buf;
    }

}
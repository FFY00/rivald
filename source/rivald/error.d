module rivald.error;

class RivalError : Exception
{

    /**
     * Default constructor
     */
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }

}
module rivald.util;

/**
 * Make sure a value passes a minimum treshhold
 */
auto min_threshold(T, P)(T a, P b)
{
    return a < b ? b : a;
}
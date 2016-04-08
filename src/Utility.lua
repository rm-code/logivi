local Utility = {};

---
-- Clamps a value to a certain range.
-- @param min (number) The minimum value to clamp to.
-- @param val (number) The value to clamp.
-- @param max (number) The maximum value to clamp to.
-- @return    (number) The clamped value.
--
function Utility.clamp( min, val, max )
    return math.max( min, math.min( val, max ));
end

---
-- Linear interpolation between a and b.
-- @param a (number) The current value.
-- @param b (number) The target value.
-- @param t (number) The time value.
-- @return  (number) The interpolated value.
--
function Utility.lerp( a, b, t )
    return a + ( b - a ) * t;
end

---
-- Returns a random sign (+ or -).
-- @return (number) Randomly returns either -1 or 1.
--
function Utility.randomSign()
    return love.math.random( 0, 1 ) == 0 and -1 or 1;
end

return Utility;

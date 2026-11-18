questions-part1

1. Explain the difference between relative delay and absolute delay based on your own understanding.

ans:Relative delay means waiting for a specified amount of time from the moment the delay statement is executed. For example, delay 1.0 makes the program wait for one second after reaching that statement.

Absolute delay means waiting until a specific time on the clock. In Ada, this can be implemented using delay until.

The main difference is that relative delay depends on when the previous operation finishes, whereas absolute delay uses a predefined time reference.

For example, if a function takes 0.2 seconds and we then use delay 1.0, the next execution starts approximately 1.2 seconds after the previous start. Repeating this causes accumulated drift.

With absolute delay, the next execution is scheduled using the original timing reference. Therefore, variations in execution time do not accumulate into the schedule, provided the deadlines are met.


2. Suppose we know the exact execution times of F1, F2, and F3. Is it possible to use relative delay to avoid drift in that case? Why/Why not?

ans: Yes, theoretically it is possible to avoid drift using relative delay if the exact execution times of all functions are known.

For example, if F1 takes 0.1 seconds and F2 takes 0.2 seconds, their combined execution time is 0.3 seconds. To maintain a one-second cycle, we could use a relative delay of 0.7 seconds after F2 finishes.

This way, the total execution time and waiting time add up to exactly one second.

so, absolute delay is generally more suitable for maintaining a periodic schedule because it uses fixed clock-time references rather than depending on the completion time of previous operations.
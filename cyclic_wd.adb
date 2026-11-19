
-- Cyclic scheduler with a watchdog:

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;

use Ada.Calendar;
use Ada.Text_IO;

-- add packages to use randam number generator

procedure cyclic_wd is
    Message : constant String := "Cyclic scheduler with watchdog";

    -- change/add your declarations here
    d : Duration := 1.0;
    Start_Time : Time := Clock;

    Next_F1 : Time := Start_Time;
    Next_F3 : Time := Start_Time + 0.5;

    Cycle : Natural := 0;

    -- Variables used for watchdog communication
    F3_Start : Time;
    Missed : Boolean := False;

    -- Variable used during resynchronisation
    Current_Time : Time;

    -- Random execution delay for F3: 100 to 800 milliseconds
    subtype Milliseconds is Integer range 100 .. 800;

    package Random_Delay is new
        Ada.Numerics.Discrete_Random (Milliseconds);

    Gen : Random_Delay.Generator;


    procedure f1 is
        Message : constant String := "f1 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
    end f1;


    procedure f2 is
        Message : constant String := "f2 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
    end f2;


    procedure f3 is
        Message : constant String := "f3 executing, time is now";
        Delay_Value : Milliseconds;
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));

        -- add a random delay here
        -- Generate a random delay
        Delay_Value := Random_Delay.Random (Gen);

        Put ("F3 random delay in milliseconds:");
        Put_Line (Integer'Image (Delay_Value));

        -- Simulate F3 execution time
        delay Duration (Delay_Value) / 1000.0;

        Put ("f3 finished, time is now");
        Put_Line (Duration'Image (Clock - Start_Time));
    end f3;


    task Watchdog is
        -- add your task entries for communication
        -- Scheduler tells watchdog that F3 is starting
        entry Start_Monitoring (F3_Start : in Time);

        -- Scheduler tells watchdog that F3 has finished
        -- Watchdog returns whether the deadline was missed
        entry F3_Finished (Deadline_Missed : out Boolean);
    end Watchdog;


    task body Watchdog is
        Deadline : Time;
    begin
        loop
            -- add your task code inside this loop
            -- Wait for the scheduler to announce F3's start
            accept Start_Monitoring (F3_Start : in Time) do
                -- F3 must finish within 0.5 seconds
                Deadline := F3_Start + 0.5;
            end Start_Monitoring;

            -- Wait for F3 to finish or for the deadline to expire
            select

                -- F3 finished before the timeout
                accept F3_Finished
                    (Deadline_Missed : out Boolean) do

                    if Clock > Deadline then
                        Put_Line
                            ("WARNING: F3 exceeded its 0.5 second deadline!");

                        Deadline_Missed := True;
                    else
                        Deadline_Missed := False;
                    end if;

                end F3_Finished;

            or
                -- The 0.5-second deadline has expired
                delay until Deadline;

                Put_Line
                    ("WARNING: F3 exceeded its 0.5 second deadline!");

                -- Let F3 finish; do not terminate it
                accept F3_Finished
                    (Deadline_Missed : out Boolean) do

                    Deadline_Missed := True;

                end F3_Finished;

            end select;
        end loop;
    end Watchdog;


begin
    Put_Line (Message);

    -- Initialise the random-number generator
    Random_Delay.Reset (Gen);

    -- Main cyclic scheduler loop
    loop
        -- change/add your code inside this loop
        delay until Next_F1;

        f1;
        f2;

        -- Execute F3 every other cycle
        if Cycle mod 2 = 0 then

            -- Wait until F3's scheduled start time
            delay until Next_F3;

            -- Record F3's start time
            F3_Start := Clock;

            -- Notify watchdog that F3 is starting
            Watchdog.Start_Monitoring (F3_Start);

            -- Execute F3
            f3;

            -- Notify watchdog that F3 has finished
            Watchdog.F3_Finished (Missed);

            -- Check if F3 missed its deadline
            if Missed then
                Put_Line ("Resynchronising the scheduler...");

                -- Find the next whole-second F1 release
                Current_Time := Clock;
                Next_F1 := Start_Time;

                while Next_F1 <= Current_Time loop
                    Next_F1 := Next_F1 + d;
                end loop;

                -- Schedule F3 0.5 seconds after the new F1
                Next_F3 := Next_F1 + 0.5;

                -- Restart the cycle pattern
                Cycle := 0;

            else
                -- Continue the original schedule
                Next_F1 := Next_F1 + d;
                Next_F3 := Next_F3 + 2.0 * d;

                Cycle := Cycle + 1;
            end if;

        else
            -- F3 is not scheduled in this cycle
            Next_F1 := Next_F1 + d;

            Cycle := Cycle + 1;
        end if;
    end loop;
end cyclic_wd;

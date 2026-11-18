with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;

procedure cyclic is
    Message: constant String := "Cyclic scheduler";
    -- change/add your declarations here
    d: Duration := 1.0;
	Start_Time: Time := Clock;
	s: Integer := 0;
        
    -- Added variables for absolute scheduling
    Next_F1: Time := Start_Time;
    Next_F3: Time := Start_Time + 0.5;
    Cycle: Natural := 0;

	procedure f1 is 
		Message: constant String := "f1 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f1;

	procedure f2 is 
		Message: constant String := "f2 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f2;

	procedure f3 is 
		Message: constant String := "f3 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f3;

	begin
        loop
            -- change/add your code inside this loop 
            -- Wait until the scheduled F1 start time
            delay until Next_F1;
            -- Execute F1 and then F2
            f1;
            f2;
            -- Execute F3 every other second
            if Cycle mod 2 = 0 then
               -- Wait until the scheduled F3 start time
               delay until Next_F3;
               -- Execute F3
               f3;
               --delay d(absolute delay is used to avoid drift);
               -- Schedule the next F3 two seconds later
               Next_F3 := Next_F3 + 2.0;

            end if;
            -- Schedule the next F1 one second later
            Next_F1 := Next_F1 + 1.0;

            -- Move to the next cycle
            Cycle := Cycle + 1;
        end loop;
end cyclic;


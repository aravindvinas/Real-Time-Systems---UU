with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;

procedure cyclic is
   Message    : constant String   := "Cyclic scheduler";
   Half_Sec   : constant Duration := 0.5;
   Start_Time : constant Time     := Clock;
   Next_Time  : Time              := Start_Time;

   procedure f1 is
      Message : constant String := "f1 executing, time is now: ";
   begin
      Put(Message);
      Put_Line(Duration'Image(Clock - Start_Time));
   end f1;

   procedure f2 is
      Message : constant String := "f2 executing, time is now: ";
   begin
      Put(Message);
      Put_Line(Duration'Image(Clock - Start_Time));
   end f2;

   procedure f3 is
      Message : constant String := "f3 executing, time is now: ";
   begin
      Put(Message);
      Put_Line(Duration'Image(Clock - Start_Time));
   end f3;

begin
   Put_Line(Message);

   loop
      -- t=1s
      f1;
      f2;

      -- t=1.0s -> t=1.5s
      Next_Time := Next_Time + Half_Sec;
      delay until Next_Time;
      
      f3;

      -- t=1.5s -> t=2s
      Next_Time := Next_Time + Half_Sec;
      delay until Next_Time;
      
      f1;
      f2;

      -- t=1s -> t=2s
      Next_Time := Next_Time + Half_Sec + Half_Sec;
      delay until Next_Time;
      
   end loop;
end cyclic;
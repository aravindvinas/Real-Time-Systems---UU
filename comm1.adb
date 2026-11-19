with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm1 is
   Message : constant String := "Process communication";

   subtype Value_Range is Integer range 0 .. 20;
   package Rand_Val is new Ada.Numerics.Discrete_Random(Value_Range);

   subtype Delay_Range is Integer range 1 .. 5;
   package Rand_Delay is new Ada.Numerics.Discrete_Random(Delay_Range);

   task buffer is
      entry Put(X : in Integer);
      entry Get(X : out Integer);
      entry Stop;
   end buffer;

   task producer is
      entry Stop;
   end producer;

   task consumer is
   end consumer;

   task body buffer is
      type BufferArray is array (0 .. 9) of Integer;
      Data  : BufferArray;
      Head  : Integer := 0;
      Tail  : Integer := 0;
      Count : Integer := 0;
      Done  : Boolean := False;
   begin
      -- Buffer must NOT print any messages per lab instructions
      loop
         select
            when Count < 10 =>
               accept Put(X : in Integer) do
                  Data(Tail) := X;
                  Tail := (Tail + 1) mod 10;
                  Count := Count + 1;
               end Put;
         or
            when Count > 0 =>
               accept Get(X : out Integer) do
                  X := Data(Head);
                  Head := (Head + 1) mod 10;
                  Count := Count - 1;
               end Get;
         or
            accept Stop do
               Done := True;
            end Stop;
         end select;

         exit when Done;
      end loop;
   end buffer;

   task body producer is
      Message : constant String := "producer executing";
      G_Val   : Rand_Val.Generator;
      G_Del   : Rand_Delay.Generator;
      Val     : Integer;
      Done    : Boolean := False;
   begin
      Put_Line(Message);
      Rand_Val.Reset(G_Val);
      Rand_Delay.Reset(G_Del);

      loop
         -- Irregular interval (0.05s to 0.25s)
         delay Duration(Rand_Delay.Random(G_Del)) * 0.05;
         Val := Rand_Val.Random(G_Val);

         -- Either deliver item to buffer or accept termination signal
         select
            accept Stop do
               Done := True;
            end Stop;
         else
            begin
               select
                  accept Stop do
                     Done := True;
                  end Stop;
               or
                  delay 0.01;
                  buffer.Put(Val);
                  Put_Line("Producer put:" & Integer'Image(Val));
               end select;
            exception
               when TASKING_ERROR =>
                  -- Buffer already terminated while producer was blocked on Put
                  Done := True;
            end;
         end select;

         exit when Done;
      end loop;
      Put_Line("Ending the producer");
   end producer;

   task body consumer is
      Message : constant String := "consumer executing";
      G_Del   : Rand_Delay.Generator;
      Val     : Integer;
      Sum     : Integer := 0;
   begin
      Put_Line(Message);
      Rand_Delay.Reset(G_Del);

      Main_Cycle :
      loop
         -- Irregular interval (0.10s to 0.50s)
         delay Duration(Rand_Delay.Random(G_Del)) * 0.10;
         buffer.Get(Val);
         Sum := Sum + Val;
         Put_Line("Consumer got:" & Integer'Image(Val) & " | Running sum:" & Integer'Image(Sum));

         exit Main_Cycle when Sum > 100;
      end loop Main_Cycle;

      -- Synchronized termination without abort or terminate statements
      buffer.Stop;
      select
         producer.Stop;
      or
         delay 0.05;
      end select;

      Put_Line("Ending the consumer");
   exception
      when TASKING_ERROR =>
         Put_Line("Buffer finished before producer");
         Put_Line("Ending the consumer");
   end consumer;

begin
   Put_Line(Message);
end comm1;
with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm2 is
   Message : constant String := "Protected Object";
   type BufferArray is array (0 .. 9) of Integer;

   subtype Value_Range is Integer range 0 .. 20;
   package Rand_Val is new Ada.Numerics.Discrete_Random(Value_Range);

   subtype Delay_Range is Integer range 1 .. 5;
   package Rand_Delay is new Ada.Numerics.Discrete_Random(Delay_Range);

   -- protected object declaration
   protected buffer is
      entry Put(X : in Integer; Accepted : out Boolean);
      entry Get(X : out Integer);
      procedure Stop;
   private
      Data    : BufferArray;
      Head    : Integer := 0;
      Tail    : Integer := 0;
      Count   : Integer := 0;
      Stopped : Boolean := False;
   end buffer;

   task producer is
      entry Stop;
   end producer;

   task consumer is
   end consumer;

   protected body buffer is
      entry Put(X : in Integer; Accepted : out Boolean) when Count < 10 or Stopped is
      begin
         if Stopped then
            Accepted := False;
         else
            Data(Tail) := X;
            Tail := (Tail + 1) mod 10;
            Count := Count + 1;
            Accepted := True;
         end if;
      end Put;

      entry Get(X : out Integer) when Count > 0 is
      begin
         X := Data(Head);
         Head := (Head + 1) mod 10;
         Count := Count - 1;
      end Get;

      procedure Stop is
      begin
         Stopped := True;
      end Stop;
   end buffer;

   task body producer is
      Message  : constant String := "producer executing";
      G_Val    : Rand_Val.Generator;
      G_Del    : Rand_Delay.Generator;
      Val      : Integer;
      Accepted : Boolean;
      Done     : Boolean := False;
   begin
      Put_Line(Message);
      Rand_Val.Reset(G_Val);
      Rand_Delay.Reset(G_Del);

      loop
         delay Duration(Rand_Delay.Random(G_Del)) * 0.05;
         Val := Rand_Val.Random(G_Val);

         select
            accept Stop do
               Done := True;
            end Stop;
         else
            buffer.Put(Val, Accepted);
            if Accepted then
               Put_Line("Producer put:" & Integer'Image(Val));
            else
               Done := True;
            end if;
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
         delay Duration(Rand_Delay.Random(G_Del)) * 0.10;
         buffer.Get(Val);
         Sum := Sum + Val;
         Put_Line("Consumer got:" & Integer'Image(Val) & " | Running sum:" & Integer'Image(Sum));

         exit Main_Cycle when Sum > 100;
      end loop Main_Cycle;

      -- Unblock producer if waiting on a full buffer and signal termination
      buffer.Stop;
      select
         producer.Stop;
      or
         delay 0.05;
      end select;

      Put_Line("Ending the consumer");
   end consumer;

begin
   Put_Line(Message);
end comm2;
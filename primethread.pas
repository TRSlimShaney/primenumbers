unit PrimeThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, generics.collections, DateUtils;

  type
    { TPrimeThread }
    TPrimeThread = class(TThread)
    private type
      TIntegerSet = specialize TList<Integer>;
    private
      JobNumber: Integer;
      Results: TIntegerSet;
      StartingNumber: Integer;
      EndingNumber: Integer;
      StartTime: TDateTime;
      FinishTime: TDateTime;
      procedure Execute; override;
      function IsPrime(primecand: Integer): Boolean;
    public
      property GetResults: TIntegerSet read Results;
      property GetJobNumber: Integer read JobNumber;
      property GetStartNumber: Integer read StartingNumber;
      property GetEndNumber: Integer read EndingNumber;
      property GetStartTime: TDateTime read StartTime;
      property GetFinishTime: TDateTime read FinishTime;
      constructor Create(thestart: Integer; theend: Integer; thejobnumber: Integer);
      destructor Destroy; override;
  end;

implementation

constructor TPrimeThread.Create(thestart: Integer; theend: Integer; thejobnumber: Integer);
begin
  inherited Create(True);
  self.FreeOnTerminate:= False;
  self.StartingNumber:= thestart;
  self.EndingNumber:= theend;
  self.JobNumber:= thejobnumber;
  self.Results:= TIntegerSet.Create;
end;

destructor TPrimeThread.Destroy;
begin
  self.Results.Free;
  inherited;
end;

procedure TPrimeThread.Execute;
var
  primecand: Integer;
begin
  self.StartTime:= Now;
  primecand:= self.StartingNumber;
  if (primecand mod 2) = 0 then begin
    Inc(primecand, 1);
  end;
  while primecand <= self.EndingNumber do begin
    if self.IsPrime(primecand) then begin
      self.Results.Add(primecand);
    end;
    Inc(primecand, 2);
  end;
  self.FinishTime:= Now;
  self.ReturnValue:= 0;
end;

function TPrimeThread.IsPrime(primecand: Integer): Boolean;
var
  factor, halfofcand: Integer;
begin
  //if (primecand mod 5) = 0 then begin
  //  Exit(False);
  //end;
  halfofcand:= primecand div 2;
  factor:= 3;
  while factor <= halfofcand do begin
    if (primecand mod factor) = 0 then begin
      Exit(False);
    end;
    Inc(factor, 2);
  end;
  Exit(True);
end;

end.


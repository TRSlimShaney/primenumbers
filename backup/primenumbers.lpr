program primenumbers;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, generics.collections, Semaphore, PrimeThread,
  DateUtil;

type
  { TPrimeNumbers }
  TPrimeNumbers = class(TCustomApplication)
  private type
    TJobList = specialize TObjectList<TPrimeThread>;
  private
    Threads: Integer;
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure WriteHelp; virtual;
  end;

{ TPrimeNumbers }

constructor TPrimeNumbers.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:= True;
end;

procedure TPrimeNumbers.WriteHelp;
begin
  { add your help code here }
  writeln(LineEnding+
  'Prime Number Finder:'+LineEnding+
  '-l: Upper limit (inclusive) for finding prime numbers'+LineEnding+
  '-t: Number of executing threads to find prime numbers'+LineEnding);
end;

procedure TPrimeNumbers.DoRun;
var
  ErrorMsg: String;
  limit, start, range, ftrange, ltrange, currentjob, jobstart, jobend: Integer;
  job: TPrimeThread;
  jobs: TJobList;
  prime: Integer;
begin
  currentjob:= 0;
  start:= 0;
  // quick check parameters
  ErrorMsg:= CheckOptions('hl:t:', 'help limit: threads:');
  if not String.IsNullOrWhiteSpace(ErrorMsg) then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  if HasOption('l', 'limit') then begin
    limit:= StrToInt(GetOptionValue('l', 'limit'));
  end
  else begin
    limit:= 100000;
  end;

  if HasOption('t', 'threads') then begin
    threads:= StrToInt(GetOptionValue('t', 'threads'));
  end
  else begin
    threads:= 1;
  end;

  jobs:= TJobList.Create;

  range:= limit - start;
  ftrange:= range div threads;
  ltrange:= range mod threads;

  while currentjob < threads do begin
    if jobs.Count = 0 then begin
      jobstart:= start;
    end
    else begin
      jobstart:= jobs.Last.GetEndNumber + 1;
    end;

    if (ltrange = 0) or (currentjob <> threads) then begin
      jobend:= jobstart + ftrange;
    end
    else begin
      jobend:= jobstart + ltrange;
    end;
    job:= TPrimeThread.Create(jobstart, jobend, currentjob);
    jobs.Add(job);
    Inc(currentjob, 1);
  end;

  for job in jobs do begin
    job.Start;
  end;

  for job in jobs do begin
    job.WaitFor;
  end;
  for job in jobs do begin
    for prime in job.GetResults do begin
      WriteLn(IntToStr(prime)+' is a prime number.');
    end;
  end;
  for job in jobs do begin
    writeln('Job '+IntToStr(job.GetJobNumber)+' finished in: '+
    IntToStr(SecondsBetween(job.GetStartTime, job.GetFinishTime))+' seconds');
  end;
  jobs.Free;
  Sleep(3000);
  // stop program loop
  Terminate;
end;

var
  Application: TPrimeNumbers;
begin
  Application:=TPrimeNumbers.Create(nil);
  Application.Title:='Prime Numbers';
  Application.Run;
  Application.Free;
end.


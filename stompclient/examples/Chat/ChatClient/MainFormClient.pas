unit MainFormClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, stompclient;

type
  TForm5 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Edit3: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    Button2: TButton;
    tmr: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Memo2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    stomp: TStompClient;
    roomname: string;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses
  StompTypes;


{$R *.dfm}

procedure TForm5.Button1Click(Sender: TObject);
begin
  roomname := '/topic/' + Edit2.Text;
  stomp := TStompClient.Create;
  stomp.EnableReceipts := false;
  stomp.Timeout := 10;
  stomp.Connect(Edit1.Text);

  //Setup for reading messages
  stomp.Subscribe(roomname, amClient);

  Button1.Enabled := False;
  Edit1.Enabled := False;
  Edit2.Enabled := False;
  Edit3.Enabled := False;
  Button2.Enabled := True;
  Memo2.Enabled := True;

  tmr.Enabled := true;
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
  stomp.Send(roomname, Memo2.Lines.Text,
    StompHeaders
      .Add('sender', Edit3.Text)
      .Add('datetime', formatdatetime('yyyy/mm/dd hh:nn:ss', now))
      .Add('persistent', 'true')
      );
  Memo2.Lines.Clear;
end;

procedure TForm5.Memo2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key = 13) and not (ssCtrl in Shift) then
  begin
    key := 0;
    Button2.Click;
  end;
end;

procedure TForm5.tmrTimer(Sender: TObject);
var
  f: TStompFrame;
begin
  f := stomp.Receive;
  if assigned(f) then
    Memo1.Lines.Add('[' + f.Headers.Value('datetime') + ' ' + f.Headers.Value('sender') + ']' + sLineBreak + f.Body);
end;

end.
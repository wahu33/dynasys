(* Dynasys, http://code.google.com/p/dynasys/
 * Copyright (C) 2009  Dynasys
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http:www.gnu.org/licenses/>.
 *)

unit ZeitSelect;

{$MODE Delphi}

interface

uses (*unix,*) Classes, LCLType, Graphics, Forms, Controls, StdCtrls, ColorBox,
  Buttons, ExtCtrls,
  Liste,SimObjekt, Dialogs, ComCtrls, ImgList, Diagram, ErrorTxt;
const
  LB_ERR = -1;
type

  { TZeitkurveDlg }

  TZeitkurveDlg = class(TForm)
    ButtonPanel: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    SrcList: TListBox;
    DstList: TListBox;
    TabSheet2: TTabSheet;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ColorBox1: TColorBox;
    ColorBox2: TColorBox;
    ColorBox3: TColorBox;
    ColorBox4: TColorBox;
    TabSheet3: TTabSheet;
    GroupBox3: TGroupBox;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioGroup2: TRadioGroup;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExAllBtnClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MoveSelected(Listbox: TListBox; Items: TStrings; maxItems:integer);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TListBox): Integer;
    procedure SetButtons;
    procedure showHelp(Sender: TObject);
  private
    SelCount:integer;
  public
    { Public declarations }
  end;

var
  ZeitkurveDlg: TZeitkurveDlg;

implementation

{$R *.lfm}

procedure TZeitkurveDlg.FormCreate(Sender: TObject);
begin
  SelCount:=0;
end;

procedure TZeitkurveDlg.FormClose(Sender: TObject);
begin
  close();
end;

procedure TZeitkurveDlg.FormPaint(Sender: TObject);
var i : integer;
begin
  SrcList.items.clear;
  SrcList.sorted:=false;
  DstList.items.clear;

  For i:=0 to ObjektListe.Count-1 do begin
    if ObjektListe.items[i].key=ZustandId then
      begin
        DstList.items.add(ObjektListe.items[i].name);
//         SrcList.items.add(ObjektListe.items[i].name);
      end;
  end;
  For i:=0 to ObjektListe.Count-1 do begin
    if (ObjektListe.items[i].key>0) and (ObjektListe.items[i].key<ZustandId)then
         SrcList.items.add(ObjektListe.items[i].name)
  end;

  if ObjektListe.Count>0 then SrcList.selected[0]:=true;
  SetButtons;
end;

procedure TZeitkurveDlg.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  //*** here
  MoveSelected(SrcList, DstList.Items,Diagram.MaxGraph);
  Inc(SelCount);
  SetItem(SrcList, Index);
end;

procedure TZeitkurveDlg.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items,MaxInt);
  Dec(SelCount);
  SetItem(DstList, Index);
end;

procedure TZeitkurveDlg.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
  myStringList: TStringList;
begin
  myStringList:=TStringList.Create;
  for I := 0 to SrcList.Items.Count - 1 do
    myStringList.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
//must use  Assign ALLWAYS?!  ListBox1.Items.Assign(myStringList);
  DstList.Items.Assign(myStringList);
  SrcList.Items.Clear;
  myStringList.Free;
  //neuzeichnen?
//  SetItem(SrcList, 0);   //better: Assign(0);?!
end;

procedure TZeitkurveDlg.ExAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
end;

procedure TZeitkurveDlg.MoveSelected(Listbox: TListBox; Items: TStrings; maxItems:integer);
var
  I: Integer;
begin
  for I := Listbox.Items.Count - 1 downto 0 do
    if Listbox.Selected[I] then begin
      if  (Items.count<maxItems) then
        begin
          Items.AddObject(Listbox.Items[I], Listbox.Items.Objects[I]);
//          Items.Add(Listbox.Items[I]);
          Listbox.Items.Delete(I);
        end
      else
       MessageDlg(ErrorTxt30, mtInformation, [mbOk], 0);
    end;
end;

procedure TZeitkurveDlg.SetButtons;
var
  SrcEmpty, DstEmpty, DstFull: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  DstFull  := DstList.Items.Count >= Diagram.MaxGraph;
  IncludeBtn.Enabled := not (SrcEmpty or DstFull);
  IncAllBtn.Enabled := SrcList.Items.Count+SrcList.Items.Count<=Diagram.MaxGraph;
                       //not (SrcEmpty or DstFull);
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end;

procedure TZeitkurveDlg.showHelp(Sender: TObject);
begin
    ShowMessage('Noch nicht verfügbar.' );
end;

function TZeitkurveDlg.GetFirstSelection(List: TListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TZeitkurveDlg.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;

end.

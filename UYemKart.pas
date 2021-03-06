unit UYemKart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, zkemkeeper_TLB,
  Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB, MemDS, DBAccess, Ora, OraCall,dateutils,
  Vcl.ComCtrls, RzBckgnd, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, cxDBEdit, Vcl.Grids, Vcl.DBGrids, CRGrid,
  cxLabel, cxDBLabel;

type
  TForm1 = class(TForm)
    edtNetAddress: TLabeledEdit;
    edtNetPort: TLabeledEdit;
    btnBaglan: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    CZKEM1: TCZKEM;
    btnkapiAc: TButton;
    OraSession1: TOraSession;
    qkayit: TOraQuery;
    Button2: TButton;
    QYmkEkle: TOraSQL;
    Qcihaz: TOraQuery;
    edtCihazAdi: TLabeledEdit;
    edtCihazTuru: TLabeledEdit;
    edtCihazTetSure: TLabeledEdit;
    Timer1: TTimer;
    QOGUN: TOraQuery;
    qpersonel: TOraQuery;
    Button3: TButton;
    btnAllKullanici: TButton;
    qtumpersonel: TOraQuery;
    btnKulGuncelle: TButton;
    Button4: TButton;
    btnonline: TButton;
    Panel3: TPanel;
    Panel4: TPanel;
    RzBackground1: TRzBackground;
    RzBackground2: TRzBackground;
    RzBackground3: TRzBackground;
    QPER_KAYIT: TOraQuery;
    QPER_KAYITGIRIS_ID: TFloatField;
    QPER_KAYITPER_NO: TFloatField;
    QPER_KAYITAD_SOYAD: TStringField;
    QPER_KAYITCIHAZ_IP: TStringField;
    QPER_KAYITKART_NO: TFloatField;
    QYmkEkleKrmd: TOraSQL;
    Button5: TButton;
    dsLoopPersonel: TOraDataSource;
    qloopPersonel: TOraQuery;
    lcbSorgu: TcxLookupComboBox;
    OraDataSource1: TOraDataSource;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxDBLabel5: TcxDBLabel;
    cxDBLabel6: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    pnlKayitEkle: TPanel;
    Button6: TButton;
    Label1: TLabel;
    procedure btnBaglanClick(Sender: TObject);
    procedure bilgi_yaz(const s:string);
    procedure Button1Click(Sender: TObject);
    procedure cihaz_Bilgisi_oku;
    procedure CZKEM1HIDNum(ASender: TObject; CardNumber: Integer);
    procedure btnkapiAcClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure QcihazAfterOpen(DataSet: TDataSet);
    procedure btnAllKullaniciClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnKulGuncelleClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnonlineClick(Sender: TObject);
    procedure cxLookupComboBox2PropertiesEditValueChanged(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CZKEM1DisConnected(Sender: TObject);
    procedure CZKEM1Connected(Sender: TObject);
  private
  DevID: integer;
   // device_id  ==1
   // Asl?nda, tcp / ip ileti?imini kulland???n?zda, bu parametre g?z ard? edilecektir,
   // yani herhangi bir tam say? uygun olacakt?r. Burada 1 kullan?yoruz.
    Commport: integer;
  public
    CONST SQL:string='select T.SIRA_NO,' + #13#10 +
'       translate(T.PERSONEL_ADI || '' '' || T.SOYADI, ''??????'', ''IOUCGS'') AD,' + #13#10 +
'       SUBSTR(T.TC_KIMLIK_NO, -4) S?fre,' + #13#10 +
'       t.kart_no,T.TC_KIMLIK_NO,' + #13#10 +
'       case when t.tc_kimlik_no in (''60058070332'',''31346037276'',''21206380710'') then 1 else 0 end yetkili' + #13#10 +
'  from per_personel t' + #13#10 +
' where coalesce(t.isten_ayrildi, ''F'') <> ''T''' + #13#10 +
'   and t.kart_no is not null %s ' + #13#10 +
' ORDER BY t.sira_no';

  end;

var
  Form1: TForm1;


implementation

{$R *.dfm}
const
  StatusNames: array[1..12] of string=(
    'Toplam Y?netici',
    'Toplam Kullan?c?',
    'toplam Parmakizi',
    'Total ?ifre ',
    'Total Y?netici',
    'Total Giri? ??k?? kayd?',
    'Ki?iye ait parmakizi numaras?',
    'Ki?iye ait kullanici numaras?',
    'Ki?iye ait giri? ??k?? kay?t numaras?',
    'Kalan parmakizi numaras?',
    'kalan kullan?c? numaras?',
    'kalan giri? ??k?? kay?t numaras?');



procedure TForm1.bilgi_yaz(const s: string);
begin
   memo1.Lines.Add(s);
  memo1.Refresh;
end;

procedure TForm1.btnAllKullaniciClick(Sender: TObject);
var
dwEnrollNumber, Name, Password,kart_no:WideString;
Privilege: integer;
 Enabled:WordBool;
begin
CZKEM1.EnableDevice(devid,false);
CZKEM1.ReadAllUserID(devid);
while CZKEM1.SSR_GetAllUserInfo(devid,dwEnrollNumber,name,Password,Privilege,Enabled) do
begin
  CZKEM1.GetStrCardNumber(kart_no);
  bilgi_yaz(format('Kull_No: %s Ad? : %s sifre : %s prive : %d ',[dwEnrollNumber,name,password,privilege]));

  QPER_KAYIT.Open;
  QPER_KAYIT.Append;
  QPER_KAYITGIRIS_ID.AsInteger:=0;
  QPER_KAYITPER_NO.AsInteger:=StrToInt(dwEnrollNumber);
  QPER_KAYITAD_SOYAD.AsString:=name;
  QPER_KAYITCIHAZ_IP.AsString:='10.42.116.251' ;
  QPER_KAYITKART_NO.AsInteger:=StrToInt(kart_no);
  QPER_KAYIT.Post;

end;
bilgi_yaz('??lem Sona Erdi ');
Application.ProcessMessages;
CZKEM1.EnableDevice(devid,True);
 OraSession1.Commit;
end;

procedure TForm1.btnBaglanClick(Sender: TObject);
var
hata :integer;
durum:Boolean;
begin
Qcihaz.Open;



    if btnBaglan.Tag=1  then
    begin
        CZKEM1.RefreshData(devid);
        CZKEM1.EnableDevice(devid,True);
        btnBaglan.Tag:=0;
        btnBaglan.Caption:='Ba?lan';
    end else
    begin

    devid:=strtoint(edtNetPort.Text);
    durum:=CZKEM1.Connect_Net(edtNetAddress.Text,devid);
    //durum:=CZKEM1.Connect_Net('10.42.116.250',devid);
    devid:=1;


    if durum then
    begin
    bilgi_yaz('Cihaza Ba?lan?ld?');
    cihaz_Bilgisi_oku;
    btnBaglan.Tag:=1;
    btnBaglan.Caption:='Ba?lant? Kes';

    if not czkem1.RegEvent(devid,65535) then
      begin
        showmessage('regEvent de hata oldu');
      end;
    end
    else
    begin
      czkem1.GetLastError(hata);
      bilgi_yaz(format('Cihaza Ba?lan?rken Hata olu?tu hataNo. =',[hata]));
    end;
    czkem1.SetDeviceTime(devid);
    bilgi_yaz(' ');
    end;
end;

procedure TForm1.btnkapiAcClick(Sender: TObject);
begin
 CZKem1.ACUnlock(DevId,5)   ;
end;

procedure TForm1.btnKulGuncelleClick(Sender: TObject);

VAR
KART_NO,SIRA_NO,AD,SIFRE:STRING;
YETKI,i:INTEGER;
AKTIF,DURUM:WordBool;


begin
qtumpersonel.Open;
qtumpersonel.First;




  i:=0;
while not qtumpersonel.Eof do
begin

KART_NO:=qtumpersonel.FieldByName('KART_NO').AsString;
SIRA_NO:=qtumpersonel.FieldByName('SIRA_NO').AsString;
AD:=qtumpersonel.FieldByName('AD').AsString;
yetki:= qtumpersonel.FieldByName('yetkili').AsInteger ;
AKTIF:=TRUE;

    CZKEM1.SetStrCardNumber(KART_NO);
    DURUM:=(CZKEM1.SSR_SetUserInfo(devid,
                        qtumpersonel.FieldByName('SIRA_NO').AsString,
                        qtumpersonel.FieldByName('AD').AsString,
                        qtumpersonel.FieldByName('Sifre').AsString, YETKI, AKTIF));

  if  DURUM then
    begin

      bilgi_YAZ(FORMAT('Kay?t Yap?ld? kartno: %s ad? : %s',[KART_NO,AD]));

    end  else
    begin
      bilgi_yaz('Kay?t Yap?l?rken hata olu?tu');
    end;
    Application.ProcessMessages;
    qtumpersonel.Next;

end;
      bilgi_yaz('??lem Bitti');
      CZKEM1.RefreshData(devid);
      CZKEM1.EnableDevice(devid, true); // cihaz? devreye al
qtumpersonel.Close;
end;

procedure TForm1.btnonlineClick(Sender: TObject);

begin

    if not czkem1.RegEvent(devid,65535) then
      begin
        repeat
        sleep(100);
        btnBaglan.Click;
        until (czkem1.RegEvent(devid,65535));

      end ;
end;

procedure TForm1.Button1Click(Sender: TObject);
 var
hata :integer;
durum:Boolean;
saat:string;
begin
//DateTimeTostring(saat,'hhnn',Now);
//
//if (strtoint(saat)>=700) and (strtoint(saat)<=800) then
//begin
//
//        begin
//        Qcihaz.Open;
//
//
//
//            if btnBaglan.Tag=1  then
//            begin
//                CZKEM1.RefreshData(devid);
//                CZKEM1.EnableDevice(devid,True);
//                btnBaglan.Tag:=0;
//                btnBaglan.Caption:='Ba?lan';
//            end else
//            begin
//
//            devid:=strtoint(edtNetPort.Text);
//            durum:=CZKEM1.Connect_Net(edtNetAddress.Text,devid);
//            //durum:=CZKEM1.Connect_Net('10.42.116.250',devid);
//            devid:=1;
//
//
//            if durum then
//            begin
//            bilgi_yaz('Cihaza Ba?lan?ld?');
//            cihaz_Bilgisi_oku;
//            btnBaglan.Tag:=1;
//            btnBaglan.Caption:='Ba?lant? Kes';
//
//            if not czkem1.RegEvent(devid,65535) then
//              begin
//                showmessage('regEvent de hata oldu');
//              end;
//            end
//            else
//            begin
//              czkem1.GetLastError(hata);
//              bilgi_yaz(format('Cihaza Ba?lan?rken Hata olu?tu hataNo. =',[hata]));
//            end;
//            czkem1.SetDeviceTime(devid);
//            bilgi_yaz(' ');
//            end;
//        end;
//end;



Memo1.Lines.Clear;
CZKEM1.RefreshData(1);
CZKEM1.EnableDevice(1,True);
btnonline.Click;


end;



procedure TForm1.Button2Click(Sender: TObject);
begin
czkem1.SetDeviceTime(devid);
end;



procedure TForm1.Button3Click(Sender: TObject);
var
dwEnrollNumber, Name, Password:WideString;
Privilege,kulrec,deger,hata: integer;
 Enabled:WordBool;

begin
  if CZKEM1.GetDeviceStatus(devid, 2, deger) then
    bilgi_yaz(format('%s: %d', [StatusNames[2],deger]))
  else
  begin
     CZKEM1.GetLastError(hata);
    bilgi_yaz(format('! GetDeviceStatus(%d) ErrorNo.=%d',[2, hata]));
    exit;
  end;


CZKEM1.EnableDevice(devid,False)  ;
CZKEM1.ReadAllUserID(devid);
while CZKEM1.SSR_GetAllUserInfo(devid,dwEnrollNumber,name,Password,Privilege,Enabled) do
begin
 CZKEM1.ssr_DeleteEnrollData(DevId, dwenrollnumber,  12);
 bilgi_yaz(format(' Kullan?c? no : %S silindi',[dwEnrollNumber]));

end;
 CZKEM1.EnableDevice(devid,True) ;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
CZKEM1.RegEvent(devid,0);
end;

procedure TForm1.Button5Click(Sender: TObject);

begin
 pnlKayitEkle.Visible:=true;
 qloopPersonel.Open;
end;

procedure TForm1.Button6Click(Sender: TObject);
VAR
KART_NO,SIRA_NO,AD,SIFRE:STRING;
YETKI,i:INTEGER;
AKTIF,DURUM:WordBool;
begin


KART_NO:=qtumpersonel.FieldByName('KART_NO').AsString;
SIRA_NO:=qtumpersonel.FieldByName('SIRA_NO').AsString;
AD:=qtumpersonel.FieldByName('AD').AsString;
yetki:= qtumpersonel.FieldByName('yetkili').AsInteger ;
AKTIF:=TRUE;

    CZKEM1.SetStrCardNumber(KART_NO);
    DURUM:=(CZKEM1.SSR_SetUserInfo(devid,
                        qtumpersonel.FieldByName('SIRA_NO').AsString,
                        qtumpersonel.FieldByName('AD').AsString,
                        qtumpersonel.FieldByName('Sifre').AsString, YETKI, AKTIF));

  if  DURUM then
    begin

      bilgi_YAZ(FORMAT('Kay?t Yap?ld? kartno: %s ad? : %s',[KART_NO,AD]));

    end  else
    begin
      bilgi_yaz('Kay?t Yap?l?rken hata olu?tu');
    end;
    Application.ProcessMessages;

end;

procedure TForm1.cihaz_Bilgisi_oku;
var
  s: widestring;
  hata, Value, i,
  dwYear, dwMonth, dwDay, dwHour, dwMinute, dwSecond: integer;
begin
  if CZKEM1.GetFirmwareVersion(devid,s) then
   bilgi_yaz('! Cihaz Versiyon no : '+s )
   else
   begin
     CZKEM1.GetLastError(hata);
     bilgi_yaz(format('Cihaz Versiyon no hata. =%D',[hata]));
   end;

  if CZKEM1.GetSerialNumber(devid,s) then
    bilgi_yaz('Cihaz Seri No : '+s)
    else
    begin
      CZKEM1.GetLastError(hata);
      bilgi_yaz(format('Cihaz Seri No hata . =%d',[hata]));
    end;

  if CZKEM1.GetDeviceTime(devid, dwYear, dwMonth, dwDay, dwHour, dwMinute, dwSecond) then
    bilgi_yaz(Format('Cihaz Saati=%d-%d-%d %d:%d:%d',[dwYear, dwMonth, dwDay, dwHour, dwMinute, dwSecond]))
  else
  begin
    CZKEM1.GetLastError(hata);
    bilgi_yaz(format('! GetDeviceTime ErrorNo.=%d',[hata]));
  end;



end;

procedure TForm1.cxLookupComboBox2PropertiesEditValueChanged(Sender: TObject);
begin
 qtumpersonel.Close;
 qtumpersonel.SQL.Clear;
 qtumpersonel.SQL.Add(format(sql,[' and T.SIRA_NO='+QuotedStr( lcbSorgu.EditValue)])) ;
 qtumpersonel.Open;
end;

procedure TForm1.CZKEM1Connected(Sender: TObject);
begin
label1.Caption:='Ba?lant? Sa?land?';
end;

procedure TForm1.CZKEM1DisConnected(Sender: TObject);
begin
Label1.Caption:='Ba?lant? Kesildi';
end;

procedure TForm1.CZKEM1HIDNum(ASender: TObject; CardNumber: Integer);
var
 saat, dakika, saniye, salise : Word;
 Strsaat,strdakika,strsaniye,strsalise:string;

begin

 decodeTime(now,saat,dakika,saniye,salise);

  if saat<10 then  strsaat:='0'+inttostr(saat) else strsaat:=inttostr(saat);
  if dakika<10 then  strdakika:='0'+inttostr(dakika) else strdakika:=inttostr(dakika);
  if saniye<10 then  strsaniye:='0'+inttostr(saniye) else strsaniye:=inttostr(saniye);


 QOGUN.ClOSE;
 QOGUN.Params[0].AsString:=strsaat+strdakika;
 QOGUN.Open;

 if QOGUN.RecordCount=0 then
 begin
 bilgi_yaz('Uygun Vardiya saati bulunamam??t?r !');
 czkem1.PlayVoiceByIndex(2);
 exit;
 end;

 qpersonel.Close;
 qpersonel.Params[0].AsString:=inttostr(cardnumber);
 qpersonel.Open;

 if qpersonel.RecordCount>0 then
 begin

   qkayit.Close;
   qkayit.Params[0].AsString:=inttostr(cardnumber);
   qkayit.Open;
   if qkayit.RecordCount>0 then
   begin

      if qkayit.FieldByName('yemek').AsString='1' then
      begin

        bilgi_yaz(format('Giri? Yap?ld? KartNo. :%d Zaman: %s',[cardnumber,DateTimeToStr(now)]));
        czkem1.PlayVoiceByIndex(0);
        if czkem1.ACUnlock(devid,strtoint(Qcihaz.FieldByName('ROLE_TETIK_SURE').AsString)) then bilgi_yaz('kap? A??ld?') else  bilgi_yaz('Kap? A??lamad? Hata Olu?tu');

        QYmkEkleKrmd.ParamByName('personel_no').AsInteger:=qkayit.FieldByName('PER_SIRANO').AsInteger;
        //QYmkEkleKrmd.ParamByName('giris_zamani').AsDateTime:=NOW;
        QYmkEkleKrmd.ParamByName('Giris_kapisi').AsInteger:=81;
        QYmkEkleKrmd.ParamByName('ogun').AsInteger:=qkayit.FieldByName('ogunkrmd').AsInteger;
        QYmkEkleKrmd.Execute;




        QYmkEkle.ParamByName('giris_id').AsInteger:=0;
        QYmkEkle.ParamByName('tc').AsString:=qkayit.FieldByName('tc_kimlik_no').AsString;
        QYmkEkle.ParamByName('ad_soyad').AsString:=qkayit.FieldByName('ad_soyad').AsString;
        QYmkEkle.ParamByName('tarih').AsDateTime:=now;
        QYmkEkle.ParamByName('yedi').AsInteger:=qkayit.FieldByName('yemek').AsInteger;
        QYmkEkle.ParamByName('ogun').AsString:=qkayit.FieldByName('ogun').AsString;
        QYmkEkle.ParamByName('cihaz_ip').AsString:=Qcihaz.FieldByName('IP_ADRES').AsString;
        QYmkEkle.ParamByName('Kart_no').AsInteger:=cardnumber;

        QYmkEkle.Execute;
        OraSession1.Commit;
        qkayit.Close;

      end  else
      begin

              czkem1.PlayVoiceByIndex(2);
              bilgi_yaz(format('Giri? Engellendi KartNo.:%d Zaman: %s Yemek hakk? bulunmuyor',[cardnumber,DateTimeToStr(now)]));


      end;

   end else
   begin

              czkem1.PlayVoiceByIndex(2);
              bilgi_yaz(format('Giri? Engellendi KartNo.:%d Zaman: %s Personel Vardiya Bulunamad?.',[cardnumber,DateTimeToStr(now)]));

   end;

 end else
 begin

 bilgi_yaz(format('Giri? Engellendi KartNo.:%d Zaman: %s Personel Bulunamad?!',[cardnumber,DateTimeToStr(now)]));



 end;





end;

procedure TForm1.FormActivate(Sender: TObject);
begin

 btnBaglan.Click;



 end;

procedure TForm1.QcihazAfterOpen(DataSet: TDataSet);
begin
edtNetAddress.Text:=Qcihaz.FieldByName('IP_ADRES').AsString;
//edtNetAddress.Text:='10.42.116.250';
edtNetPort.Text:=Qcihaz.FieldByName('PORT_NO').AsString;
edtCihazAdi.Text:=Qcihaz.FieldByName('CIHAZ_ADI').AsString;
edtCihazTuru.Text:=Qcihaz.FieldByName('CIHAZ_TUR').AsString;
edtCihazTetSure.Text:=Qcihaz.FieldByName('ROLE_TETIK_SURE').AsString;
end;

end.

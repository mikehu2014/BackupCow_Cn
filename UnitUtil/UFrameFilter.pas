unit UFrameFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UFmFilter, StdCtrls, ExtCtrls, UFileBaseInfo, siComp, UMainForm;

type
  TFrameFilterPage = class(TFrame)
    plInclude: TPanel;
    gbIncludeFilter: TGroupBox;
    FrameInclude: TFrameFilter;
    plExclude: TPanel;
    gbExcludeFilter: TGroupBox;
    FrameExclude: TFrameFilter;
    siLang_FrameFilterPage: TsiLang;
  private
    { Private declarations }
  public
    procedure IniFrame;
    procedure SetDefaultStatus;
  public
    procedure SetRootPathList( RootPathList : TStringList );
    procedure SetIncludeFilterList( FilterList : TFileFilterList );
    procedure SetExcludeFilterList( FilterList : TFileFilterList );
  public
    function getIncludeFilterList : TFileFilterList;
    function getExcludeFilterList : TFileFilterList;
  public
    procedure RefreshLanguage;
  end;

implementation

{$R *.dfm}

{ TFrame1 }

function TFrameFilterPage.getExcludeFilterList: TFileFilterList;
begin
  Result := FrameExclude.getFilterList;
end;

function TFrameFilterPage.getIncludeFilterList: TFileFilterList;
begin
  Result := FrameInclude.getFilterList;
end;

procedure TFrameFilterPage.IniFrame;
begin
  FrameInclude.SetIsInclude( True );
  FrameExclude.SetIsInclude( False );
end;

procedure TFrameFilterPage.RefreshLanguage;
begin
  FrameInclude.RefreshLanguage;
  FrameExclude.RefreshLanguage;
end;

procedure TFrameFilterPage.SetDefaultStatus;
begin
  FrameInclude.SetDefaultStatus;
  FrameExclude.SetDefaultStatus;
end;

procedure TFrameFilterPage.SetExcludeFilterList(FilterList: TFileFilterList);
begin
  FrameExclude.SetFilterList( FilterList );
end;

procedure TFrameFilterPage.SetIncludeFilterList(FilterList: TFileFilterList);
begin
  FrameInclude.SetFilterList( FilterList );
end;

procedure TFrameFilterPage.SetRootPathList(RootPathList: TStringList);
begin
  FrameInclude.SetRootPathList( RootPathList );
  FrameExclude.SetRootPathList( RootPathList );
end;

end.

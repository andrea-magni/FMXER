unit Routes.menu;

interface

procedure DefineMenuRoute;

implementation

uses
 System.Types, System.UITypes
, FMX.Types, FMX.ListView.Appearances
, Skia, QRCode.Render

, FMXER.Navigator
, FMXER.ScaffoldForm
, FMXER.ListViewFrame
, FMXER.QRCodeFrame
, FMXER.BackgroundFrame
, FMXER.StackFrame
, FMXER.SVGFrame
, FMXER.AnimatedImageFrame
, FMXER.UI.Consts
, SubjectStand

, Utils
;

procedure DefineMenuRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('menu'
  , procedure (AMenu: TScaffoldForm)
    begin
      AMenu.Title := 'Select an entry';

      AMenu.SetTitleDetailContentAsFrame<TBackgroundFrame>(
        procedure (B: TBackgroundFrame)
        begin
          B.Fill.Color := TAlphaColorRec.Aliceblue;
          B.Align := TAlignLayout.Right;
          B.Width := AMenu.TitleLayout.Height - 4;
          B.Margins.Rect := RectF(2, 2, 2, 2);

          B.SetContentAsFrame<TQRCodeFrame>(
            procedure (AQR: TQRCodeFrame)
            begin
              AQR.Margins.Rect := RectF(2, 2, 2, 2);
              AQR.Content := 'https://github.com/andrea-magni/FMXER';

//              AQR.QRCode.Svg.OverrideColor := TAppColors.PrimaryColor;
              AQR.OnBeforePaint :=
                procedure (APaint: ISkPaint; AModules: T2DBooleanArray)
                begin
                  APaint.Shader := TSkShader.MakeColor(TAppColors.PrimaryColor);
                end;

            end
          );
        end
      );

      AMenu.SetContentAsFrame<TStackFrame>(
        procedure (Stack: TStackFrame)
        begin
          Stack.AddFrame<TListViewFrame>(
            procedure (AList: TListViewFrame)
            begin
//              AList.ListView.Transparent := True;
              AList.ItemAppearance := 'ListItemRightDetail';

              AList.AddItem('Item spinner 1', '1 second', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('spinner', True);
                  TDelayedAction.Execute(1000
                  , procedure
                    begin
                      Navigator.CloseRoute('spinner', True);
                    end
                  );
                end
              );

              AList.AddItem('Item spinner 2', '5 seconds', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('spinner', True);
                  TDelayedAction.Execute(5000
                  , procedure
                    begin
                      Navigator.CloseRoute('spinner', True);
                    end
                  );
                end
              );

              AList.AddItem('Item spinner 3', '10 seconds', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('spinner', True);
                  TDelayedAction.Execute(10000
                  , procedure
                    begin
                      Navigator.CloseRoute('spinner', True);
                    end
                  );
                end
              );

              AList.AddItem('Image', 'Tap to close', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('image');
                end
              );

              AList.AddItem('Animated Image', 'Tap to close', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('animatedImage');
                end
              );

              AList.AddItem('SVG Image', 'Tap to close', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('SVGImage');
                end
              );


              AList.AddItem('QR Code', 'Tap to close', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('QRCode');
                end
              );

              AList.AddItem('Free hand drawing', '', -1
              , procedure (const AItem: TListViewItem)
                begin
                  Navigator.RouteTo('freeHandDrawing');
                end
              );
            end
          );

//          Stack.AddFrame<TSVGFrame>(
//            procedure (SVG: TSVGFrame)
//            begin
//              SVG.HitTest := False;
//              SVG.Opacity := 0.2;
//              SVG.LoadFromFile(LocalFile('tesla.svg'));
//            end
//          );
          AMenu.AddActionButton('Spin'
          , procedure
            begin
              Stack.AddFrame<TAnimatedImageFrame>(
                procedure (Ani: TAnimatedImageFrame)
                begin
//                  Ani.HitTest := True;
                  Ani.Opacity := 0.2;
                  Ani.ContentImage.LoadFromFile(LocalFile('spinner-loader.json'));

//                  TDelayedAction.Execute(3000
//                  , procedure
//                    begin
//                      Stack.CloseFrame('spinner');
//                    end
//                  );
                  Ani.OnTapHandler :=
                    procedure (AObj: TFMXObject; APoint: TPointF)
                    begin
                      Stack.CloseFrame('spinner');
                    end;

                end
              , 'spinner'
              );
            end
          );

        end
      );
    end
  );
end;

end.


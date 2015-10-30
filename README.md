# HVC-C2W iOS-SDK by OMRON


### 1. SDK内容
  iPhone,iPadからオムロン製HVC-C2Wを制御するためのSDK(α版)を提供します。

### 2. ご利用方法
  2.1 同梱の「HVC-C2W SDK使用許諾契約」をお読み頂き、
      同意いただける場合のみ本SDKをご利用頂けます。

  2.2 本SDKをご利用頂くにはSensingEggProjectメンバーサイトへの　
      メンバー登録（無料）が必要です。
      http://plus-sensing.omron.co.jp/member/sdk/

  2.3 WebAPIを使用してサーバにアクセスするためにはAppIDとApiKeyが必要となります。
      SensingEggProjcetメンバーサイト内の「APIキー申請フォーム」よりご申請下さい。


### 3. ディレクトリ構成
      doc/
         HVC-C2W_WebAPI仕様書      HVC-C2Wを使用する為のクラウドサーバWebAPI仕様書
         HVC-C2W_API仕様書         HVC-C2Wを制御する為のAPI仕様書
      bin/                         HVC-C2W SDKバイナリファイル本体
      src/usr_include/
         HvcwSdkAPI.h              SDKヘッダファイル
         HvcwTypedef.h             typedef定義
         HvcwCommonDef.h           エラーコード定義
		 
      sample/
         StandardDemo/             基本サンプルデモプロジェクト(Android Studio)


###[ご使用にあたって]
* 本ソースコード、バイナリファイルおよびドキュメントの著作権はオムロンに帰属します。
* 本ソースコード及びバイナリファイルは動作を保証するものではありません。

### 謝辞
  本ソフトウェアには、以下フリーウェアソフトウェアが含まれています。
  
*****************************************************
OpenH264   http://www.openh264.org
*****************************************************
Copyright (c) 2013, Cisco Systems
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
*************************************************
FFmpeg  https://www.ffmpeg.org
************************************************
https://www.ffmpeg.org/legal.html

************************************************
LDPC FEC Codes  http://planete-bcast.inrialpes.fr/articlec6d0.html?id_article=16
************************************************

LDPC FEC Licence
Thursday 6 April 2006. 

This codec is: 
-  Copyright (c) 2002-2006 INRIA - All rights reserved. 
-  Copyright (c) 1995-2003 by Radford M. Neal

It includes large portions of code written by Radford Neal and available here.

The code coming from Radford M. Neal is distributed under the following licence:
Permission is granted for anyone to copy, use, modify, or distribute these programs and accompanying documents for any purpose, provided this copyright notice is retained and prominently displayed, along with a note saying that the original programs are available from Radford Neal’s web page, and note is made of any changes made to these programs. These programs and documents are distributed without any warranty, express or implied. As the programs were written for research purposes only, they have not been tested to the degree that would be advisable in any important application. All use of these programs is entirely at the user’s own risk. 
The code coming from INRIA is distributed under the GNU/LGPL licence, with the following additional requirement:
 This copyright notice must be retained and prominently displayed, along with a note saying that the original programs are available from Vincent Roca’s web page, and note is made of any changes made to these programs.  
This FEC library can therefore freely be used in any program, commercial or not, open-source or not.


----
オムロン株式会社  
Copyright(C) 2015 OMRON Corporation, All Rights Reserved.

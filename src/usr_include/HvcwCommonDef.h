/*-------------------------------------------------------------------*/
/*  Copyright(C) 2015 by OMRON Corporation                           */
/*  All Rights Reserved.                                             */
/*                                                                   */
/*   This source code is the Confidential and Proprietary Property   */
/*   of OMRON Corporation.  Any unauthorized use, reproduction or    */
/*   transfer of this software is strictly prohibited.               */
/*                                                                   */
/*-------------------------------------------------------------------*/

#ifndef __HVCWCOMMONDEF_H
#define __HVCWCOMMONDEF_H

/* SDK Error Code */
#define HVCW_SUCCESS                 1               /* 処理成功                         */
#define HVCW_INVALID_PARAM           2               /* パラメータが不正                 */
#define HVCW_NOT_READY               3               /* 処理準備が出来ていない           */
#define HVCW_BUSY                    4               /* 処理を受け付け出来ない           */
#define HVCW_NOT_SUPPORT             5               /* 要求された処理はサポートされない */
#define HVCW_TIMEOUT                 6               /* 通信タイムアウト                 */
#define HVCW_NOT_FOUND               7               /* 処理対象が見つからない           */
#define HVCW_FAILURE                 8               /* その他エラー（上記エラー以外）   */
#define HVCW_NOT_INITIALIZE          11              /* SDKが初期化されていない          */
#define HVCW_DISCONNECTED            12              /* カメラとの接続が切断されている   */
#define HVCW_NOHANDLE                20              /* ハンドルエラー                   */
#define HVCW_NO_FACE                 30              /* 顔検出結果が0                    */
#define HVCW_PLURAL_FACES            31              /* 顔検出結果が複数存在する         */
#define HVCW_INVALID_RECEIVEDATA     40              /* 受信データが不正                 */
#define HVCW_NOFILE                  50              /* ファイルが存在しない             */
#define HVCW_SD_NOT_INSERT           61              /* SDカード未挿入                   */
#define HVCW_SD_READ                 62              /* SDカード読み込みエラー           */

#endif /* __HVCWCOMMONDEF_H */

/*-------------------------------------------------------------------*/
/*  Copyright(C) 2015 by OMRON Corporation                           */
/*  All Rights Reserved.                                             */
/*                                                                   */
/*   This source code is the Confidential and Proprietary Property   */
/*   of OMRON Corporation.  Any unauthorized use, reproduction or    */
/*   transfer of this software is strictly prohibited.               */
/*                                                                   */
/*-------------------------------------------------------------------*/

#ifndef __HVCWTYPEDEF_H
#define __HVCWTYPEDEF_H

typedef     signed char         HVCW_CHAR;       /* 8bits •¶šŒ^            */
typedef     unsigned char       HVCW_UINT8;      /* 8bits •„†–³•¶šŒ^      */
typedef     unsigned char       HVCW_BYTE;       /* 8bits •„†–³•¶šŒ^      */
typedef     signed short        HVCW_INT16;      /* 16bits •„†•t’Z’·®”Œ^ */
typedef     unsigned short      HVCW_UINT16;     /* 16bits •„†–³’Z’·®”Œ^ */
typedef     signed int          HVCW_BOOL;       /* 32bits •„†•t®”Œ^     */
typedef     signed int          HVCW_INT32;      /* 32bits •„†•t®”Œ^     */
typedef     unsigned int        HVCW_UINT32;     /* 32bits •„†–³®”Œ^     */
typedef     void                HVCW_VOID;       /* Œ^‚È‚µ                  */

#ifndef     FALSE
    #define     FALSE               0
#endif

#ifndef     TRUE
    #define     TRUE                1
#endif

#ifndef     NULL
    #define     NULL                0
#endif

#endif /* __HVCWTYPEDEF_H */

/*
 *  NSFUtils.c
 *  NetSoulAdiumPlugin
 *
 *  Created by ReeB on Sun May 09 2004.
 */
 
 /*
  * Copyright (C) 2004 CUISSARD Vincent <cuissa_v@epita.fr>
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of the GNU General Public License as published by the Free 
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
  *
  * This program is distributed in the hope that it will be useful, but 
  * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
  * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
  * for more details.
  *
  * You should have received a copy of the GNU General Public License along 
  * with this program; if not, write to the Free Software Foundation, Inc., 675 
  * Mass Ave, Cambridge, MA 02139, USA.
  */

#include "NSFUtils.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

char		*strip_return(char *str)
{
    int		i;
    int		j;
    
    for (i = j = 0; str[i]; ++i, ++j)
	if (str[i] == '\\' && str[i + 1] && str[i + 1] == 'n')
	{
	    str[j] = '\n';
	    i++;
	}
	else
	    str[j] = str[i];
    str[j] = 0;
    return str;
}

char		*backslash_return(char *str)
{
    int		i;
    int		len;
    char	*nstr = NULL;
    
    for (i = len = 0; str[i]; ++i, ++len)
	if (str[i] == '\n')
	    ++len;
    
    nstr = calloc(len + 1, sizeof (char));
    
    assert (nstr != NULL);
    
    while (*str)
    {
	if (*str == '\n')
	    sprintf(nstr, "%s\\n", nstr);
	else
	    sprintf(nstr, "%s%c", nstr, *str);
	++str;
    }
    
    return nstr;
}

char		*spec_2_msg(char *str)
{
    int		i;
    int		j;
    char	nb[5];
    
    memset(nb, 0, 5);
    for (i = j = 0; str[i]; i++, j++)
	if (str[i] == '%' && str[i + 1] &&
	    ((str[i + 1] >= '0' && str[i + 1] <= '9') ||
	     (str[i + 1] >= 'A' && str[i + 1] <= 'F') ||
	     (str[i + 1] >= 'a' && str[i + 1] <= 'f')))
	{
	    sprintf(nb, "0x%.2s", str + i + 1);
	    str[j] = strtol(nb, 0, 16);
	    i += 2;
	}
	    else
		str[j] = str[i];
    str[j] = 0;
    return str;
}

char		*msg_2_spec(unsigned char *str)
{
    char	*tmp;
    
    for (tmp = ""; str && *str; str++)
	if ((*str >= 'a' && *str <= 'z') ||
	    (*str >= 'A' && *str <= 'Z') ||
	    (*str >= '0' && *str <= '9') ||
	    *str == '_' || *str == '-' || *str == '.')
	    asprintf(&tmp, "%s%c", tmp, *str);
	else
	    asprintf(&tmp, "%s%%%02X", tmp, *str);
    return tmp;
}

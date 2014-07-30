/*
 *  NSFUtils.h
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


// Implements the url_(en)decode and backslash removed in order to respect
// NetSoul protocol


char		*strip_return(char *str);
char		*backslash_return(char *str);
char		*spec_2_msg(char *str);
char		*msg_2_spec(unsigned char *str);


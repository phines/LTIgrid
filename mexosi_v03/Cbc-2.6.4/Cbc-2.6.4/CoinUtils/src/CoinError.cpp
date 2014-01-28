/* $Id: CoinError.cpp 1191 2009-07-25 08:38:12Z forrest $ */
// Copyright (C) 2005, International Business Machines
// Corporation and others.  All Rights Reserved.

#include "CoinError.hpp"

bool CoinError::printErrors_ = false;

/** A function to block the popup windows that windows creates when the code
    crashes */
#ifdef HAVE_WINDOWS_H
#include <windows.h>
void WindowsErrorPopupBlocker()
{
  SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);
}
#else
void WindowsErrorPopupBlocker() {}
#endif

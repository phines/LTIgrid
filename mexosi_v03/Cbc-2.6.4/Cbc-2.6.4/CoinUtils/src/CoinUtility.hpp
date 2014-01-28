/* $Id: CoinUtility.hpp 1191 2009-07-25 08:38:12Z forrest $ */
#ifndef CoinUtility_h_
#define CoinUtility_h_

#include "CoinSort.hpp"

template <typename S, typename T>
CoinPair<S,T> CoinMakePair(const S& s, const T& t)
{ return CoinPair<S,T>(s, t); }

template <typename S, typename T, typename U>
CoinTriple<S,T,U> CoinMakeTriple(const S& s, const T& t, const U& u)
{ return CoinTriple<S,T,U>(s, t, u); }

#endif

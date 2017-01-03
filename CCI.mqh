//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of CCI Strategy based on the Commodity Channel Index indicator.
 *
 * @docs
 * - https://docs.mql4.com/indicators/iCCI
 * - https://www.mql5.com/en/docs/indicators/iCCI
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input string __CCI_Parameters__ = "-- Settings for the Commodity Channel Index indicator --"; // >>> CCI <<<
#ifdef __input__ input int CCI_Period_Fast = 12; // Period Fast
#ifdef __input__ input int CCI_Period_Slow = 20; // Period Slow
#ifdef __input__ input ENUM_APPLIED_PRICE CCI_Applied_Price = 0; // Applied Price
#ifdef __input__ input double CCI_SignalLevel = 0.00000000; // Signal level
#ifdef __input__ input int CCI_SignalMethod = 0; // Signal method for M1 (0-

class CCI: public Strategy {
protected:

  double cci[H1][FINAL_ENUM_INDICATOR_INDEX][FINAL_MA_ENTRY];
  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

    public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Commodity Channel Index indicator.
    for (int i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      cci[index][i][FAST] = iCCI(symbol, tf, CCI_Period_Fast, CCI_Applied_Price, i);
      cci[index][i][SLOW] = iCCI(symbol, tf, CCI_Period_Slow, CCI_Applied_Price, i);
    }
    success = (bool) cci[index][CURR][SLOW];
  }

  /**
   * Checks whether signal is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int cmd, ENUM_TIMEFRAMES tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    bool result = FALSE; int period = Timeframe::TfToIndex(tf);
    UpdateIndicator(S_CCI, tf);
    if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(S_CCI, tf, 0);
    if (signal_level  == EMPTY) signal_level  = GetStrategySignalLevel(S_CCI, tf, 0.0);
    switch (cmd) {
      //   if(iCCI(Symbol(),0,12,PRICE_TYPICAL,0)>iCCI(Symbol(),0,20,PRICE_TYPICAL,0)) return(0);
      /*
        //11. Commodity Channel Index
        //Buy: 1. indicator crosses +100 from below upwards. 2. Crossing -100 from below upwards. 3.
        //Sell: 1. indicator crosses -100 from above downwards. 2. Crossing +100 downwards. 3.
        if ((iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)<100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)>=100)||(iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)<-100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)>=-100))
        {f11=1;}
        if ((iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)>-100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)<=-100)||(iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)>100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)<=100))
        {f11=-1;}
      */
      case OP_BUY:
        /*
          bool result = CCI[period][CURR][LOWER] != 0.0 || CCI[period][PREV][LOWER] != 0.0 || CCI[period][FAR][LOWER] != 0.0;
          if ((signal_method &   1) != 0) result &= Open[CURR] > Close[CURR];
          if ((signal_method &   2) != 0) result &= !CCI_On_Sell(tf);
          if ((signal_method &   4) != 0) result &= CCI_On_Buy(fmin(period + 1, M30));
          if ((signal_method &   8) != 0) result &= CCI_On_Buy(M30);
          if ((signal_method &  16) != 0) result &= CCI[period][FAR][LOWER] != 0.0;
          if ((signal_method &  32) != 0) result &= !CCI_On_Sell(M30);
          */
      break;
      case OP_SELL:
        /*
          bool result = CCI[period][CURR][UPPER] != 0.0 || CCI[period][PREV][UPPER] != 0.0 || CCI[period][FAR][UPPER] != 0.0;
          if ((signal_method &   1) != 0) result &= Open[CURR] < Close[CURR];
          if ((signal_method &   2) != 0) result &= !CCI_On_Buy(tf);
          if ((signal_method &   4) != 0) result &= CCI_On_Sell(fmin(period + 1, M30));
          if ((signal_method &   8) != 0) result &= CCI_On_Sell(M30);
          if ((signal_method &  16) != 0) result &= CCI[period][FAR][UPPER] != 0.0;
          if ((signal_method &  32) != 0) result &= !CCI_On_Buy(M30);
          */
      break;
    }
    result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    return result;
  }
};

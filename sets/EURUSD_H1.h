//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_CCI_EURUSD_H1_Params : Stg_CCI_Params {
  Stg_CCI_EURUSD_H1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H1;
    CCI_Period = 2;
    CCI_Applied_Price = 3;
    CCI_Shift = 0;
    CCI_TrailingStopMethod = 6;
    CCI_TrailingProfitMethod = 11;
    CCI_SignalOpenLevel = 36;
    CCI_SignalBaseMethod = 0;
    CCI_SignalOpenMethod1 = 195;
    CCI_SignalOpenMethod2 = 0;
    CCI_SignalCloseLevel = 36;
    CCI_SignalCloseMethod1 = 1;
    CCI_SignalCloseMethod2 = 0;
    CCI_MaxSpread = 6;
  }
};

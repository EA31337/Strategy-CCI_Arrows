//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_CCI_Arrows_EURUSD_H4_Params : Stg_CCI_Arrows_Params {
  Stg_CCI_Arrows_EURUSD_H4_Params() {
    CCI_Arrows_Period = 12;
    CCI_Arrows_Applied_Price = 3;
    CCI_Arrows_Shift = 0;
    CCI_Arrows_SignalOpenMethod = 0;
    CCI_Arrows_SignalOpenLevel = 36;
    CCI_Arrows_SignalCloseMethod = 1;
    CCI_Arrows_SignalCloseLevel = 36;
    CCI_Arrows_PriceLimitMethod = 0;
    CCI_Arrows_PriceLimitLevel = 2;
    CCI_Arrows_MaxSpread = 10;
  }
} stg_cci_h4;

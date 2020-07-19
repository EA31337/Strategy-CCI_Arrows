//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_CCI_Arrows_EURUSD_M1_Params : Stg_CCI_Arrows_Params {
  Stg_CCI_Arrows_EURUSD_M1_Params() {
    CCI_Arrows_Period = 21;
    CCI_Arrows_Applied_Price = PRICE_CLOSE;
    CCI_Arrows_Shift = 0;
    CCI_Arrows_SignalOpenMethod = 0;
    CCI_Arrows_SignalOpenLevel = 0;
    CCI_Arrows_SignalCloseMethod = 0;
    CCI_Arrows_SignalCloseLevel = 0;
    CCI_Arrows_PriceLimitMethod = 0;
    CCI_Arrows_PriceLimitLevel = 0;
    CCI_Arrows_TickFilterMethod = 0;
    CCI_Arrows_MaxSpread = 2;
  }
} stg_cci_arrays_m1;

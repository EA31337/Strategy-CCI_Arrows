//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_CCIA_EURUSD_H1_Params : Stg_CCIA_Params {
  Stg_CCIA_EURUSD_H1_Params() {
    CCIA_Period = 12;
    CCIA_Applied_Price = 3;
    CCIA_Shift = 0;
    CCIA_SignalOpenMethod = 0;
    CCIA_SignalOpenLevel = 36;
    CCIA_SignalCloseMethod = 1;
    CCIA_SignalCloseLevel = 36;
    CCIA_PriceLimitMethod = 0;
    CCIA_PriceLimitLevel = 2;
    CCIA_MaxSpread = 6;
  }
} stg_cci_h1;

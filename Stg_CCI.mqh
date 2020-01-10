//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements CCI strategy based on the Commodity Channel Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_CCI.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __CCI_Parameters__ = "-- CCI strategy params --";  // >>> CCI <<<
INPUT int CCI_Active_Tf = 15;  // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32...)
INPUT int CCI_Shift = 1;       // Shift (0 for default)
INPUT ENUM_TRAIL_TYPE CCI_TrailingStopMethod = 1;    // Trail stop method
INPUT ENUM_TRAIL_TYPE CCI_TrailingProfitMethod = 1;  // Trail profit method
INPUT int CCI_Period = 58;                           // Period
INPUT ENUM_APPLIED_PRICE CCI_Applied_Price = 2;      // Applied Price
INPUT double CCI_SignalOpenLevel = 98;               // Signal open level (100 by default)
INPUT int CCI1_SignalBaseMethod = 34;                // Signal base method (0-63)
INPUT int CCI1_OpenCondition1 = 680;                 // Open condition 1 (0-1023)
INPUT int CCI1_OpenCondition2 = 0;                   // Open condition 2 (0-1023)
INPUT ENUM_MARKET_EVENT CCI1_CloseCondition = 31;    // Close condition for M1
double CCI_MaxSpread = 6.0;                          // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_CCI_Params : Stg_Params {
  unsigned int CCI_Period;
  ENUM_APPLIED_PRICE CCI_Applied_Price;
  int CCI_Shift;
  ENUM_TRAIL_TYPE CCI_TrailingStopMethod;
  ENUM_TRAIL_TYPE CCI_TrailingProfitMethod;
  double CCI_SignalOpenLevel;
  long CCI_SignalBaseMethod;
  long CCI_SignalOpenMethod1;
  long CCI_SignalOpenMethod2;
  double CCI_SignalCloseLevel;
  ENUM_MARKET_EVENT CCI_SignalCloseMethod1;
  ENUM_MARKET_EVENT CCI_SignalCloseMethod2;
  double CCI_MaxSpread;

  // Constructor: Set default param values.
  Stg_CCI_Params()
      : CCI_Period(::CCI_Period),
        CCI_Applied_Price(::CCI_Applied_Price),
        CCI_Shift(::CCI_Shift),
        CCI_TrailingStopMethod(::CCI_TrailingStopMethod),
        CCI_TrailingProfitMethod(::CCI_TrailingProfitMethod),
        CCI_SignalOpenLevel(::CCI_SignalOpenLevel),
        CCI_SignalBaseMethod(::CCI_SignalBaseMethod),
        CCI_SignalOpenMethod1(::CCI_SignalOpenMethod1),
        CCI_SignalOpenMethod2(::CCI_SignalOpenMethod2),
        CCI_SignalCloseLevel(::CCI_SignalCloseLevel),
        CCI_SignalCloseMethod1(::CCI_SignalCloseMethod1),
        CCI_SignalCloseMethod2(::CCI_SignalCloseMethod2),
        CCI_MaxSpread(::CCI_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_CCI : public Strategy {
 public:
  Stg_CCI(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_CCI *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_CCI_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_CCI_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_CCI_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_CCI_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_CCI_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_CCI_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_CCI_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    CCI_Params adx_params(_params.CCI_Period, _params.CCI_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_CCI);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_CCI(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.CCI_SignalBaseMethod, _params.CCI_SignalOpenMethod1, _params.CCI_SignalOpenMethod2,
                       _params.CCI_SignalCloseMethod1, _params.CCI_SignalCloseMethod2, _params.CCI_SignalOpenLevel,
                       _params.CCI_SignalCloseLevel);
    sparams.SetStops(_params.CCI_TrailingProfitMethod, _params.CCI_TrailingStopMethod);
    sparams.SetMaxSpread(_params.CCI_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_CCI(sparams, "CCI");
    return _strat;
  }

  /**
   * Check if CCI indicator is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    double cci_0 = ((Indi_CCI *)this.Data()).GetValue(0);
    double cci_1 = ((Indi_CCI *)this.Data()).GetValue(1);
    double cci_2 = ((Indi_CCI *)this.Data()).GetValue(2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = cci_0 > 0 && cci_0 < -_signal_level1;
        if (_signal_method != 0) {
          if (METHOD(_signal_method, 0)) _result &= cci_0 > cci_1;
          if (METHOD(_signal_method, 1)) _result &= cci_1 > cci_2;
          if (METHOD(_signal_method, 2)) _result &= cci_1 < -_signal_level1;
          if (METHOD(_signal_method, 3)) _result &= cci_2 < -_signal_level1;
          if (METHOD(_signal_method, 4)) _result &= cci_0 - cci_1 > cci_1 - cci_2;
          if (METHOD(_signal_method, 5)) _result &= cci_2 > 0;
        }
        break;
      case ORDER_TYPE_SELL:
        _result = cci_0 > 0 && cci_0 > _signal_level1;
        if (_signal_method != 0) {
          if (METHOD(_signal_method, 0)) _result &= cci_0 < cci_1;
          if (METHOD(_signal_method, 1)) _result &= cci_1 < cci_2;
          if (METHOD(_signal_method, 2)) _result &= cci_1 > _signal_level1;
          if (METHOD(_signal_method, 3)) _result &= cci_2 > _signal_level1;
          if (METHOD(_signal_method, 4)) _result &= cci_1 - cci_0 > cci_2 - cci_1;
          if (METHOD(_signal_method, 5)) _result &= cci_2 < 0;
        }
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};

//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements CCI strategy based on the Commodity Channel Index indicator.
 */

// Includes.
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __CCI_Arrows_Parameters__ = "-- CCI Arrows strategy params --";  // >>> CCI Arrows <<<
INPUT int CCI_Arrows_Period = 0;                                              // Period
INPUT ENUM_APPLIED_PRICE CCI_Arrows_Applied_Price = PRICE_CLOSE;              // Applied Price
INPUT int CCI_Arrows_Shift = 0;                                               // Shift (0 for default)
int CCI_Arrows_SignalOpenMethod = 0;                                    // Signal open method (-63-63)
double CCI_Arrows_SignalOpenLevel = 0;                                  // Signal open level (-49-49)
int CCI_Arrows_SignalOpenFilterMethod = 0;                              // Signal open filter method
int CCI_Arrows_SignalOpenBoostMethod = 0;                               // Signal open boost method
int CCI_Arrows_SignalCloseMethod = 0;                                   // Signal close method
double CCI_Arrows_SignalCloseLevel = 18;                                // Signal close level
int CCI_Arrows_PriceLimitMethod = 0;                                    // Price limit method
double CCI_Arrows_PriceLimitLevel = 1;                                  // Price limit level
double CCI_Arrows_MaxSpread = 6.0;                                            // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_CCI_Arrows_Params : StgParams {
  unsigned int CCI_Arrows_Period;
  ENUM_APPLIED_PRICE CCI_Arrows_Applied_Price;
  int CCI_Arrows_Shift;
  int CCI_Arrows_SignalOpenMethod;
  double CCI_Arrows_SignalOpenLevel;
  int CCI_Arrows_SignalOpenFilterMethod;
  int CCI_Arrows_SignalOpenBoostMethod;
  int CCI_Arrows_SignalCloseMethod;
  double CCI_Arrows_SignalCloseLevel;
  int CCI_Arrows_PriceLimitMethod;
  double CCI_Arrows_PriceLimitLevel;
  double CCI_Arrows_MaxSpread;

  // Constructor: Set default param values.
  Stg_CCI_Arrows_Params()
      : CCI_Arrows_Period(::CCI_Arrows_Period),
        CCI_Arrows_Applied_Price(::CCI_Arrows_Applied_Price),
        CCI_Arrows_Shift(::CCI_Arrows_Shift),
        CCI_Arrows_SignalOpenMethod(::CCI_Arrows_SignalOpenMethod),
        CCI_Arrows_SignalOpenLevel(::CCI_Arrows_SignalOpenLevel),
        CCI_Arrows_SignalOpenFilterMethod(::CCI_Arrows_SignalOpenFilterMethod),
        CCI_Arrows_SignalOpenBoostMethod(::CCI_Arrows_SignalOpenBoostMethod),
        CCI_Arrows_SignalCloseMethod(::CCI_Arrows_SignalCloseMethod),
        CCI_Arrows_SignalCloseLevel(::CCI_Arrows_SignalCloseLevel),
        CCI_Arrows_PriceLimitMethod(::CCI_Arrows_PriceLimitMethod),
        CCI_Arrows_PriceLimitLevel(::CCI_Arrows_PriceLimitLevel),
        CCI_Arrows_MaxSpread(::CCI_Arrows_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_CCI_Arrows : public Strategy {
 public:
  Stg_CCI_Arrows(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_CCI_Arrows *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_CCI_Arrows_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_CCI_Arrows_Params>(_params, _tf, stg_cci_arrays_m1, stg_cci_arrays_m5, stg_cci_arrays_m15,
                                           stg_cci_arrays_m30, stg_cci_arrays_h1, stg_cci_arrays_h4, stg_cci_arrays_h4);
    }
    // Initialize strategy parameters.
    CCI_Arrows_Params ccia_params(_params.CCI_Arrows_Period, _params.CCI_Arrows_Applied_Price,
                                  _params.CCI_Arrows_Shift);
    ccia_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_CCI_Arrows(ccia_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.CCI_Arrows_SignalOpenMethod, _params.CCI_Arrows_SignalOpenLevel,
                       _params.CCI_Arrows_SignalOpenFilterMethod, _params.CCI_Arrows_SignalOpenBoostMethod,
                       _params.CCI_Arrows_SignalCloseMethod, _params.CCI_Arrows_SignalCloseLevel);
    sparams.SetPriceLimits(_params.CCI_Arrows_PriceLimitMethod, _params.CCI_Arrows_PriceLimitLevel);
    sparams.SetMaxSpread(_params.CCI_Arrows_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_CCI_Arrows(sparams, "CCI Arrows");
    return _strat;
  }

  /**
   * Check if CCI indicator is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    Chart *_chart = this.Chart();
    Indi_CCI_Arrows *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double level = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = _indi[CURR].value[CCI_ARROWS_DOWN] > 0;
        break;
      case ORDER_TYPE_SELL:
        _result = _indi[CURR].value[CCI_ARROWS_UP] > 0;
        break;
    }
    return _result;
  }

  /**
   * Check strategy's opening signal additional filter.
   */
  bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost (when enabled).
   */
  double SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, double _level = 0.0) {
    Indi_CCI_Arrows *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
    }
    return _result;
  }
};
